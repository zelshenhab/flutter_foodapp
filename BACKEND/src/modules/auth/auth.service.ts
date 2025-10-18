import { supabase } from "../../core/config/supabase";
import { randomBytes } from "crypto";
import { addMinutes, isBefore } from "date-fns";
import { signAccess, signRefresh } from "../../core/utils/jwt";
import type { JwtUser } from "./auth.types";

const OTP_TTL_MIN = 2;
const MAX_ATTEMPTS = 5;
const DEV_CODE = "111111"; // use real SMS in prod

export async function requestOtp(phone: string) {
  const requestId = randomBytes(12).toString("hex");
  const code = process.env.NODE_ENV === "production"
    ? (Math.floor(100000 + Math.random() * 900000)).toString()
    : DEV_CODE;

  const { error } = await supabase
    .from('OtpRequest')
    .insert({
      phone,
      code,
      requestId,
      expiresAt: addMinutes(new Date(), OTP_TTL_MIN).toISOString(),
    });

  if (error) throw { status: 500, message: "Failed to create OTP request" };

  // TODO: send SMS in prod
  return { requestId, ttl: OTP_TTL_MIN * 60, devCode: code === DEV_CODE ? DEV_CODE : undefined };
}

export async function verifyOtp(phone: string, requestId: string, code: string) {
  const { data: rec, error: fetchError } = await supabase
    .from('OtpRequest')
    .select('*')
    .eq('requestId', requestId)
    .single();

  if (fetchError || !rec || rec.phone !== phone) {
    throw { status: 400, message: "Invalid request" };
  }

  if (rec.attempts >= MAX_ATTEMPTS) {
    throw { status: 429, message: "Too many attempts" };
  }

  if (isBefore(new Date(rec.expiresAt), new Date())) {
    throw { status: 400, message: "Code expired" };
  }

  // increment attempts
  const { error: updateError } = await supabase
    .from('OtpRequest')
    .update({ attempts: rec.attempts + 1 })
    .eq('id', rec.id);

  if (updateError) {
    throw { status: 500, message: "Failed to update attempts" };
  }

  if (rec.code !== code) {
    throw { status: 400, message: "Invalid code" };
  }

  // upsert user
  const { data: user, error: userError } = await supabase
    .from('User')
    .upsert({
      phone,
    }, {
      onConflict: 'phone'
    })
    .select()
    .single();

  if (userError) {
    throw { status: 500, message: "Failed to create/update user" };
  }

  const payload: JwtUser = { id: user.id, phone: user.phone };
  const accessToken = signAccess(payload);
  const refreshToken = signRefresh(payload);

  const { error: tokenError } = await supabase
    .from('RefreshToken')
    .insert({
      userId: user.id,
      token: refreshToken,
      expiresAt: new Date(Date.now() + 30 * 24 * 3600 * 1000).toISOString(), // 30d
    });

  if (tokenError) {
    throw { status: 500, message: "Failed to create refresh token" };
  }

  return { accessToken, refreshToken, user };
}

export async function me(userId: number) {
  const { data, error } = await supabase
    .from('User')
    .select('*')
    .eq('id', userId)
    .single();

  if (error) {
    throw { status: 404, message: "User not found" };
  }

  return data;
}

export async function refresh(oldToken: string) {
  const { data: rec, error: fetchError } = await supabase
    .from('RefreshToken')
    .select('*')
    .eq('token', oldToken)
    .single();

  if (fetchError || !rec || rec.revoked) {
    throw { status: 401, message: "Invalid refresh token" };
  }

  if (isBefore(new Date(rec.expiresAt), new Date())) {
    throw { status: 401, message: "Refresh expired" };
  }

  const { data: user, error: userError } = await supabase
    .from('User')
    .select('*')
    .eq('id', rec.userId)
    .single();

  if (userError || !user) {
    throw { status: 401, message: "User not found" };
  }

  const payload: JwtUser = { id: user.id, phone: user.phone };
  const accessToken = signAccess(payload);
  return { accessToken };
}