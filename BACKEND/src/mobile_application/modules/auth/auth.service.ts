import { supabase } from "../../../core/config/supabase";
import { randomBytes } from "crypto";
import { addMinutes, isBefore, differenceInDays } from "date-fns";
import { signAccess, signRefresh } from "../../../core/utils/jwt";
import { sendOtpEmail } from "../../../core/config/sendgrid";
import { sendOtpEmailSMTP } from "../../../core/config/smtp";

const OTP_TTL_MIN = 15;
const MAX_ATTEMPTS = 5;
const INACTIVITY_LIMIT_DAYS = 30; // Force re-login after 30 days of inactivity
const SESSION_EXTEND_DAYS = 30; // Extend session by 30 days when active

// --------------------
// REQUEST OTP (unchanged)
// --------------------
export async function requestOtp(email: string) {
  const moderatorEnabled =
    process.env.ENABLE_MODERATOR_BYPASS === "true";

  const moderatorEmail = process.env.MODERATOR_EMAIL;
  const moderatorCode = process.env.MODERATOR_CODE || "915287";

  if (moderatorEnabled && email === moderatorEmail) {
    console.log("Moderator OTP bypass activated");
    return {
      requestId: "moderator-request",
      ttl: OTP_TTL_MIN * 60,
    };
  }

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

// --------------------
// VERIFY OTP (updated with metadata)
// --------------------
export async function verifyOtp(
  email: string,
  requestId: string,
  code: string,
  userAgent?: string,
  ipAddress?: string
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

    // Update user activity
    await supabase
      .from("User")
      .update({
        lastActiveAt: new Date().toISOString(),
        lastRefreshAt: new Date().toISOString(),
      })
      .eq("id", user.id);

    await supabase.from("RefreshToken").insert({
      userId: user.id,
      token: refreshToken,
      expiresAt: new Date(
        Date.now() + SESSION_EXTEND_DAYS * 24 * 60 * 60 * 1000
      ).toISOString(),
      userAgent,
      ipAddress,
      lastUsedAt: new Date().toISOString(),
    });

    return { accessToken, refreshToken, user };
  }

  // Normal OTP verification
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

  // Get or create user
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

  // Update user activity
  await supabase
    .from("User")
    .update({
      lastActiveAt: new Date().toISOString(),
      lastRefreshAt: new Date().toISOString(),
    })
    .eq("id", user.id);

  await supabase.from("RefreshToken").insert({
    userId: user.id,
    token: refreshToken,
    expiresAt: new Date(
      Date.now() + SESSION_EXTEND_DAYS * 24 * 60 * 60 * 1000
    ).toISOString(),
    userAgent,
    ipAddress,
    lastUsedAt: new Date().toISOString(),
  });

  return { accessToken, refreshToken, user };
}

// --------------------
// ME (unchanged)
// --------------------
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

// --------------------
// REFRESH (CRITICAL FIX - with rotation)
// --------------------
export async function refresh(
  oldToken: string,
  userAgent?: string,
  ipAddress?: string
) {
  // Find the refresh token
  const { data: rec, error: fetchError } = await supabase
    .from("RefreshToken")
    .select("*")
    .eq("token", oldToken)
    .single();

  if (fetchError || !rec || rec.revoked) {
    throw { status: 401, message: "Invalid refresh token" };
  }

  if (isBefore(new Date(rec.expiresAt), new Date())) {
    throw { status: 401, message: "Refresh expired" };
  }

  // Get user
  const { data: user } = await supabase
    .from("User")
    .select("*")
    .eq("id", rec.userId)
    .single();

  if (!user) {
    throw { status: 401, message: "User not found" };
  }

  // Check for inactivity
  if (user.lastRefreshAt) {
    const inactiveDays = differenceInDays(
      new Date(),
      new Date(user.lastRefreshAt)
    );
    
    if (inactiveDays > INACTIVITY_LIMIT_DAYS) {
      // Revoke the old token
      await supabase
        .from("RefreshToken")
        .update({ 
          revoked: true, 
          revokedAt: new Date().toISOString() 
        })
        .eq("id", rec.id);
      
      throw { status: 401, message: "Session expired due to inactivity" };
    }
  }

  // Generate NEW tokens
  const payload = { id: user.id, email: user.email };
  const newAccessToken = signAccess(payload);
  const newRefreshToken = signRefresh(payload);

  // Invalidate the OLD refresh token (rotation)
  await supabase
    .from("RefreshToken")
    .update({ 
      revoked: true,
      revokedAt: new Date().toISOString(),
      replacedBy: newRefreshToken,
      replacedAt: new Date().toISOString()
    })
    .eq("id", rec.id);

  // Create NEW refresh token
  await supabase.from("RefreshToken").insert({
    userId: user.id,
    token: newRefreshToken,
    expiresAt: new Date(
      Date.now() + SESSION_EXTEND_DAYS * 24 * 60 * 60 * 1000
    ).toISOString(),
    userAgent: userAgent || rec.userAgent,
    ipAddress: ipAddress || rec.ipAddress,
    lastUsedAt: new Date().toISOString(),
  });

  // Update user activity
  await supabase
    .from("User")
    .update({
      lastActiveAt: new Date().toISOString(),
      lastRefreshAt: new Date().toISOString(),
    })
    .eq("id", user.id);

  // Return BOTH tokens
  return { 
    accessToken: newAccessToken, 
    refreshToken: newRefreshToken 
  };
}

// --------------------
// LOGOUT (updated)
// --------------------
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
    .update({ 
      revoked: true,
      revokedAt: new Date().toISOString()
    })
    .eq("id", rec.id);

  return { success: true };
}

// --------------------
// DELETE ACCOUNT (unchanged)
// --------------------
export async function deleteAccount(userId: number) {
  await supabase
    .from("RefreshToken")
    .delete()
    .eq("userId", userId);

  const { error } = await supabase
    .from("User")
    .delete()
    .eq("id", userId);

  if (error) {
    throw { status: 500, message: "Failed to delete user" };
  }

  return { success: true };
}