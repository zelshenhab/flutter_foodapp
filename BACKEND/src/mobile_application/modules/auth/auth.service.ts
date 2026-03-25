import { supabase } from "../../../core/config/supabase";
import { randomBytes } from "crypto";
import { addMinutes, isBefore } from "date-fns";
import { signAccess, signRefresh } from "../../../core/utils/jwt";
import { sendOtpEmail } from "../../../core/config/sendgrid";
import { sendOtpEmailSMTP } from "../../../core/config/smtp";

const OTP_TTL_MIN = 15;
const MAX_ATTEMPTS = 5;

// --------------------
// REQUEST OTP
// --------------------
export async function requestOtp(email: string) {
  const moderatorEnabled =
    process.env.ENABLE_MODERATOR_BYPASS === "true";

  const moderatorEmail = process.env.MODERATOR_EMAIL;
  const moderatorCode = process.env.MODERATOR_CODE || "915287";

  // 🛡 Moderator bypass (NO email sending)
  if (moderatorEnabled && email === moderatorEmail) {
    console.log("Moderator OTP bypass activated");

    return {
      requestId: "moderator-request",
      ttl: OTP_TTL_MIN * 60,
    };
  }

  // -------- Normal OTP Flow --------
  const requestId = randomBytes(12).toString("hex");
  const code = Math.floor(100000 + Math.random() * 900000).toString();

  console.log("Sending OTP to:", email);

  const { error } = await supabase.from("OtpRequest").insert({
    email,
    code,
    requestId,
    attempts: 0,
    expiresAt: addMinutes(new Date(), OTP_TTL_MIN).toISOString(),
  });

  if (error) {
    console.error("Supabase OTP insert error:", error);
    throw { status: 500, message: "Failed to create OTP request" };
  }

  const provider = process.env.EMAIL_PROVIDER || "sendgrid";

  try {
    if (provider === "smtp") {
      await sendOtpEmailSMTP({
        to: email,
        code,
        ttlMinutes: OTP_TTL_MIN,
      });
      console.log("OTP email sent via SMTP");
    } else {
      await sendOtpEmail({
        to: email,
        code,
        ttlMinutes: OTP_TTL_MIN,
      });
      console.log("OTP email sent via SendGrid");
    }
  } catch (e: any) {
    console.error("Email send error:", e?.message || e);
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
  const moderatorEnabled =
    process.env.ENABLE_MODERATOR_BYPASS === "true";

  const moderatorEmail = process.env.MODERATOR_EMAIL;
  const moderatorCode = process.env.MODERATOR_CODE || "123456";

  // Moderator bypass login
  if (
    moderatorEnabled &&
    email === moderatorEmail &&
    code === moderatorCode
  ) {
    console.log("Moderator login successful");

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

export async function logout(refreshToken: string) {
  const { data: rec } = await supabase
    .from("RefreshToken")
    .select("*")
    .eq("token", refreshToken)
    .single();

  if (!rec) {
    throw { status: 401, message: "Invalid refresh token" };
  }

  await supabase
    .from("RefreshToken")
    .update({ revoked: true })
    .eq("id", rec.id);

  return { success: true };
}

export async function deleteAccount(userId: number) {

  // remove refresh tokens
  await supabase
    .from("RefreshToken")
    .delete()
    .eq("userId", userId);

  // delete user
  const { error } = await supabase
    .from("User")
    .delete()
    .eq("id", userId);

  if (error) {
    throw { status: 500, message: "Failed to delete user" };
  }

  return { success: true };
}