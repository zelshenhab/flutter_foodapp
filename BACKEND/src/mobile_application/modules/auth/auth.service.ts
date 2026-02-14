import { supabase } from "../../../core/config/supabase";
import { randomBytes } from "crypto";
import { addMinutes, isBefore } from "date-fns";
import { signAccess, signRefresh } from "../../../core/utils/jwt";
import { sendOtpEmail } from "../../../core/config/sendgrid";

const OTP_TTL_MIN = 2;
const MAX_ATTEMPTS = 5;

export async function requestOtp(email: string) {
  const requestId = randomBytes(12).toString("hex");

  // Always generate real random code
  const code = Math.floor(100000 + Math.random() * 900000).toString();

  console.log("📧 Sending OTP to:", email);
  console.log("🔐 Generated OTP:", code);

  // Store OTP in database
  const { error } = await supabase.from("OtpRequest").insert({
    email,
    code,
    requestId,
    attempts: 0,
    expiresAt: addMinutes(new Date(), OTP_TTL_MIN).toISOString(),
  });

  if (error) {
    console.error("❌ Supabase OTP insert error:", error);
    throw { status: 500, message: "Failed to create OTP request" };
  }

  // Send email via SendGrid
  try {
    await sendOtpEmail({
      to: email,
      code,
      ttlMinutes: OTP_TTL_MIN,
    });
    console.log("✅ OTP email sent successfully");
  } catch (e: any) {
    console.error(
      "❌ SendGrid error:",
      e?.response?.body || e?.message || e
    );
    throw { status: 500, message: "Failed to send OTP email" };
  }

  return {
    requestId,
    ttl: OTP_TTL_MIN * 60,
  };
}

export async function verifyOtp(
  email: string,
  requestId: string,
  code: string
) {
  const { data: rec, error: fetchError } = await supabase
    .from("OtpRequest")
    .select("*")
    .eq("requestId", requestId)
    .single();

  if (fetchError || !rec || rec.email !== email) {
    throw { status: 400, message: "Invalid request" };
  }

  if (rec.attempts >= MAX_ATTEMPTS) {
    throw { status: 429, message: "Too many attempts" };
  }

  if (isBefore(new Date(rec.expiresAt), new Date())) {
    throw { status: 400, message: "Code expired" };
  }

  await supabase
    .from("OtpRequest")
    .update({ attempts: rec.attempts + 1 })
    .eq("id", rec.id);

  if (rec.code !== code) {
    throw { status: 400, message: "Invalid code" };
  }

  const { data: user, error: userError } = await supabase
    .from("User")
    .upsert({ email }, { onConflict: "email" })
    .select()
    .single();

  if (userError || !user) {
    throw { status: 500, message: "Failed to create/update user" };
  }

  const payload = { id: user.id, email: user.email };

  const accessToken = signAccess(payload);
  const refreshToken = signRefresh(payload);

  await supabase.from("RefreshToken").insert({
    userId: user.id,
    token: refreshToken,
    expiresAt: new Date(
      Date.now() + 30 * 24 * 60 * 60 * 1000
    ).toISOString(),
  });

  return { accessToken, refreshToken, user };
}


export async function me(userId: number) {
  const { data, error } = await supabase
    .from("User")
    .select("*")
    .eq("id", userId)
    .single();

  if (error || !data) {
    throw { status: 404, message: "User not found" };
  }

  return data;
}

// =============================
// REFRESH TOKEN
// =============================
export async function refresh(oldToken: string) {
  const { data: rec } = await supabase
    .from("RefreshToken")
    .select("*")
    .eq("token", oldToken)
    .single();

  if (!rec || rec.revoked) {
    throw { status: 401, message: "Invalid refresh token" };
  }

  if (isBefore(new Date(rec.expiresAt), new Date())) {
    throw { status: 401, message: "Refresh expired" };
  }

  const { data: user } = await supabase
    .from("User")
    .select("*")
    .eq("id", rec.userId)
    .single();

  if (!user) {
    throw { status: 401, message: "User not found" };
  }

  const accessToken = signAccess({
    id: user.id,
    email: user.email,
  });

  return { accessToken };
}
