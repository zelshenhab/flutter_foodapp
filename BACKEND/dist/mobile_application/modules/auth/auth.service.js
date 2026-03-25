"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requestOtp = requestOtp;
exports.verifyOtp = verifyOtp;
exports.me = me;
exports.refresh = refresh;
exports.logout = logout;
exports.deleteAccount = deleteAccount;
const supabase_1 = require("../../../core/config/supabase");
const crypto_1 = require("crypto");
const date_fns_1 = require("date-fns");
const jwt_1 = require("../../../core/utils/jwt");
const sendgrid_1 = require("../../../core/config/sendgrid");
const smtp_1 = require("../../../core/config/smtp");
const OTP_TTL_MIN = 15;
const MAX_ATTEMPTS = 5;
// --------------------
// REQUEST OTP
// --------------------
async function requestOtp(email) {
    const moderatorEnabled = process.env.ENABLE_MODERATOR_BYPASS === "true";
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
    const requestId = (0, crypto_1.randomBytes)(12).toString("hex");
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    console.log("Sending OTP to:", email);
    const { error } = await supabase_1.supabase.from("OtpRequest").insert({
        email,
        code,
        requestId,
        attempts: 0,
        expiresAt: (0, date_fns_1.addMinutes)(new Date(), OTP_TTL_MIN).toISOString(),
    });
    if (error) {
        console.error("Supabase OTP insert error:", error);
        throw { status: 500, message: "Failed to create OTP request" };
    }
    const provider = process.env.EMAIL_PROVIDER || "sendgrid";
    try {
        if (provider === "smtp") {
            await (0, smtp_1.sendOtpEmailSMTP)({
                to: email,
                code,
                ttlMinutes: OTP_TTL_MIN,
            });
            console.log("OTP email sent via SMTP");
        }
        else {
            await (0, sendgrid_1.sendOtpEmail)({
                to: email,
                code,
                ttlMinutes: OTP_TTL_MIN,
            });
            console.log("OTP email sent via SendGrid");
        }
    }
    catch (e) {
        console.error("Email send error:", e?.message || e);
        throw { status: 500, message: "Failed to send OTP email" };
    }
    return {
        requestId,
        ttl: OTP_TTL_MIN * 60,
    };
}
async function verifyOtp(email, requestId, code) {
    const moderatorEnabled = process.env.ENABLE_MODERATOR_BYPASS === "true";
    const moderatorEmail = process.env.MODERATOR_EMAIL;
    const moderatorCode = process.env.MODERATOR_CODE || "123456";
    // Moderator bypass login
    if (moderatorEnabled &&
        email === moderatorEmail &&
        code === moderatorCode) {
        console.log("Moderator login successful");
        const { data: user, error: userError } = await supabase_1.supabase
            .from("User")
            .upsert({ email }, { onConflict: "email" })
            .select()
            .single();
        if (userError || !user) {
            throw { status: 500, message: "Failed to create/update user" };
        }
        const payload = { id: user.id, email: user.email };
        const accessToken = (0, jwt_1.signAccess)(payload);
        const refreshToken = (0, jwt_1.signRefresh)(payload);
        await supabase_1.supabase.from("RefreshToken").insert({
            userId: user.id,
            token: refreshToken,
            expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
        });
        return { accessToken, refreshToken, user };
    }
    const { data: rec, error: fetchError } = await supabase_1.supabase
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
    if ((0, date_fns_1.isBefore)(new Date(rec.expiresAt), new Date())) {
        throw { status: 400, message: "Code expired" };
    }
    await supabase_1.supabase
        .from("OtpRequest")
        .update({ attempts: rec.attempts + 1 })
        .eq("id", rec.id);
    if (rec.code !== code) {
        throw { status: 400, message: "Invalid code" };
    }
    const { data: user, error: userError } = await supabase_1.supabase
        .from("User")
        .upsert({ email }, { onConflict: "email" })
        .select()
        .single();
    if (userError || !user) {
        throw { status: 500, message: "Failed to create/update user" };
    }
    const payload = { id: user.id, email: user.email };
    const accessToken = (0, jwt_1.signAccess)(payload);
    const refreshToken = (0, jwt_1.signRefresh)(payload);
    await supabase_1.supabase.from("RefreshToken").insert({
        userId: user.id,
        token: refreshToken,
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
    });
    return { accessToken, refreshToken, user };
}
async function me(userId) {
    const { data, error } = await supabase_1.supabase
        .from("User")
        .select("*")
        .eq("id", userId)
        .single();
    if (error || !data) {
        throw { status: 404, message: "User not found" };
    }
    return data;
}
async function refresh(oldToken) {
    const { data: rec } = await supabase_1.supabase
        .from("RefreshToken")
        .select("*")
        .eq("token", oldToken)
        .single();
    if (!rec || rec.revoked) {
        throw { status: 401, message: "Invalid refresh token" };
    }
    if ((0, date_fns_1.isBefore)(new Date(rec.expiresAt), new Date())) {
        throw { status: 401, message: "Refresh expired" };
    }
    const { data: user } = await supabase_1.supabase
        .from("User")
        .select("*")
        .eq("id", rec.userId)
        .single();
    if (!user) {
        throw { status: 401, message: "User not found" };
    }
    const accessToken = (0, jwt_1.signAccess)({
        id: user.id,
        email: user.email,
    });
    return { accessToken };
}
async function logout(refreshToken) {
    const { data: rec } = await supabase_1.supabase
        .from("RefreshToken")
        .select("*")
        .eq("token", refreshToken)
        .single();
    if (!rec) {
        throw { status: 401, message: "Invalid refresh token" };
    }
    await supabase_1.supabase
        .from("RefreshToken")
        .update({ revoked: true })
        .eq("id", rec.id);
    return { success: true };
}
async function deleteAccount(userId) {
    // remove refresh tokens
    await supabase_1.supabase
        .from("RefreshToken")
        .delete()
        .eq("userId", userId);
    // delete user
    const { error } = await supabase_1.supabase
        .from("User")
        .delete()
        .eq("id", userId);
    if (error) {
        throw { status: 500, message: "Failed to delete user" };
    }
    return { success: true };
}
//# sourceMappingURL=auth.service.js.map