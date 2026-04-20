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
const loyalty_service_1 = require("../loyalty/loyalty.service");
const OTP_TTL_MIN = 15;
const MAX_ATTEMPTS = 5;
const INACTIVITY_LIMIT_DAYS = 30; // Force re-login after 30 days of inactivity
const SESSION_EXTEND_DAYS = 30; // Extend session by 30 days when active
// --------------------
// REQUEST OTP
// --------------------
async function requestOtp(email) {
    const moderatorEnabled = process.env.ENABLE_MODERATOR_BYPASS === "true";
    const moderatorEmail = process.env.MODERATOR_EMAIL;
    const moderatorCode = process.env.MODERATOR_CODE || "915287";
    if (moderatorEnabled && email === moderatorEmail) {
        console.log("Moderator OTP bypass activated");
        return {
            requestId: "moderator-request",
            ttl: OTP_TTL_MIN * 60,
        };
    }
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
// --------------------
// VERIFY OTP (UPDATED with proper welcome bonus)
// --------------------
async function verifyOtp(email, requestId, code, userAgent, ipAddress) {
    const moderatorEnabled = process.env.ENABLE_MODERATOR_BYPASS === "true";
    const moderatorEmail = process.env.MODERATOR_EMAIL;
    const moderatorCode = process.env.MODERATOR_CODE || "123456";
    // Moderator bypass login
    if (moderatorEnabled &&
        email === moderatorEmail &&
        code === moderatorCode) {
        console.log("Moderator login successful");
        // Check if user exists first
        let { data: user, error: userError } = await supabase_1.supabase
            .from("User")
            .select("*")
            .eq("email", email)
            .maybeSingle();
        let isNewUser = false;
        if (!user) {
            // Create new user
            console.log(`Creating new moderator user: ${email}`);
            const { data: newUser, error: createError } = await supabase_1.supabase
                .from("User")
                .insert({ email })
                .select()
                .single();
            if (createError || !newUser) {
                console.error("Failed to create moderator user:", createError);
                throw { status: 500, message: "Failed to create user" };
            }
            user = newUser;
            isNewUser = true;
            console.log(`✅ New moderator user created: ${user.id}`);
        }
        else {
            console.log(`✅ Existing moderator user logged in: ${user.id}`);
        }
        // Award welcome bonus for new users
        if (isNewUser) {
            try {
                console.log(`🎁 Awarding welcome bonus to moderator user ${user.id}...`);
                await (0, loyalty_service_1.awardWelcomeBonus)(user.id);
                console.log(`✅ Welcome bonus awarded to moderator user ${user.id}`);
                // Refresh user data
                const { data: refreshedUser } = await supabase_1.supabase
                    .from("User")
                    .select("*")
                    .eq("id", user.id)
                    .single();
                if (refreshedUser) {
                    user = refreshedUser;
                }
            }
            catch (error) {
                console.error("❌ Failed to award welcome bonus:", error);
            }
        }
        const payload = { id: user.id, email: user.email };
        const accessToken = (0, jwt_1.signAccess)(payload);
        const refreshToken = (0, jwt_1.signRefresh)(payload);
        // Update user activity
        await supabase_1.supabase
            .from("User")
            .update({
            lastActiveAt: new Date().toISOString(),
            lastRefreshAt: new Date().toISOString(),
        })
            .eq("id", user.id);
        await supabase_1.supabase.from("RefreshToken").insert({
            userId: user.id,
            token: refreshToken,
            expiresAt: new Date(Date.now() + SESSION_EXTEND_DAYS * 24 * 60 * 60 * 1000).toISOString(),
            userAgent,
            ipAddress,
            lastUsedAt: new Date().toISOString(),
        });
        return { accessToken, refreshToken, user };
    }
    // Normal OTP verification
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
    // Check if user exists FIRST (using maybeSingle to avoid errors)
    let { data: user, error: userError } = await supabase_1.supabase
        .from("User")
        .select("*")
        .eq("email", email)
        .maybeSingle();
    let isNewUser = false;
    if (!user) {
        // Create new user
        console.log(`Creating new user: ${email}`);
        const { data: newUser, error: createError } = await supabase_1.supabase
            .from("User")
            .insert({ email })
            .select()
            .single();
        if (createError || !newUser) {
            console.error("Failed to create user:", createError);
            throw { status: 500, message: "Failed to create user" };
        }
        user = newUser;
        isNewUser = true;
        console.log(`✅ New user created: ${user.id}`);
    }
    else {
        console.log(`✅ Existing user logged in: ${user.id}`);
    }
    // Award welcome bonus for NEW users only
    if (isNewUser) {
        try {
            console.log(`🎁 Awarding welcome bonus to user ${user.id}...`);
            const result = await (0, loyalty_service_1.awardWelcomeBonus)(user.id);
            console.log(`✅ Welcome bonus result:`, result);
            // Refresh user data to get updated points
            const { data: refreshedUser } = await supabase_1.supabase
                .from("User")
                .select("*")
                .eq("id", user.id)
                .single();
            if (refreshedUser) {
                user = refreshedUser;
                console.log(`✅ User ${user.id} now has ${user.loyaltyPoints} loyalty points`);
            }
        }
        catch (error) {
            console.error("❌ Failed to award welcome bonus:", error);
        }
    }
    const payload = { id: user.id, email: user.email };
    const accessToken = (0, jwt_1.signAccess)(payload);
    const refreshToken = (0, jwt_1.signRefresh)(payload);
    // Update user activity
    await supabase_1.supabase
        .from("User")
        .update({
        lastActiveAt: new Date().toISOString(),
        lastRefreshAt: new Date().toISOString(),
    })
        .eq("id", user.id);
    await supabase_1.supabase.from("RefreshToken").insert({
        userId: user.id,
        token: refreshToken,
        expiresAt: new Date(Date.now() + SESSION_EXTEND_DAYS * 24 * 60 * 60 * 1000).toISOString(),
        userAgent,
        ipAddress,
        lastUsedAt: new Date().toISOString(),
    });
    return { accessToken, refreshToken, user };
}
// --------------------
// ME
// --------------------
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
// --------------------
// REFRESH (with rotation)
// --------------------
async function refresh(oldToken, userAgent, ipAddress) {
    // Find the refresh token
    const { data: rec, error: fetchError } = await supabase_1.supabase
        .from("RefreshToken")
        .select("*")
        .eq("token", oldToken)
        .single();
    if (fetchError || !rec || rec.revoked) {
        throw { status: 401, message: "Invalid refresh token" };
    }
    if ((0, date_fns_1.isBefore)(new Date(rec.expiresAt), new Date())) {
        throw { status: 401, message: "Refresh expired" };
    }
    // Get user
    const { data: user } = await supabase_1.supabase
        .from("User")
        .select("*")
        .eq("id", rec.userId)
        .single();
    if (!user) {
        throw { status: 401, message: "User not found" };
    }
    // Check for inactivity
    if (user.lastRefreshAt) {
        const inactiveDays = (0, date_fns_1.differenceInDays)(new Date(), new Date(user.lastRefreshAt));
        if (inactiveDays > INACTIVITY_LIMIT_DAYS) {
            // Revoke the old token
            await supabase_1.supabase
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
    const newAccessToken = (0, jwt_1.signAccess)(payload);
    const newRefreshToken = (0, jwt_1.signRefresh)(payload);
    // Invalidate the OLD refresh token (rotation)
    await supabase_1.supabase
        .from("RefreshToken")
        .update({
        revoked: true,
        revokedAt: new Date().toISOString(),
        replacedBy: newRefreshToken,
        replacedAt: new Date().toISOString()
    })
        .eq("id", rec.id);
    // Create NEW refresh token
    await supabase_1.supabase.from("RefreshToken").insert({
        userId: user.id,
        token: newRefreshToken,
        expiresAt: new Date(Date.now() + SESSION_EXTEND_DAYS * 24 * 60 * 60 * 1000).toISOString(),
        userAgent: userAgent || rec.userAgent,
        ipAddress: ipAddress || rec.ipAddress,
        lastUsedAt: new Date().toISOString(),
    });
    // Update user activity
    await supabase_1.supabase
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
// LOGOUT
// --------------------
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
        .update({
        revoked: true,
        revokedAt: new Date().toISOString()
    })
        .eq("id", rec.id);
    return { success: true };
}
// --------------------
// DELETE ACCOUNT
// --------------------
async function deleteAccount(userId) {
    // Remove refresh tokens
    await supabase_1.supabase
        .from("RefreshToken")
        .delete()
        .eq("userId", userId);
    // Delete user
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