"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendOtp = sendOtp;
exports.verifyOtp = verifyOtp;
const db_1 = require("../../core/config/db");
const jwt_1 = require("../../core/utils/jwt");
const supabase_1 = require("../../core/config/supabase");
async function ensureSupabaseUserByPhone(phone) {
    if (!supabase_1.supabase)
        return (0, db_1.ensureUserByPhone)(phone);
    // Try to find by phone
    const { data: usersByPhone, error: findErr } = await supabase_1.supabase
        .from("users")
        .select("user_id,name,phone,email,address,notifications,language_code,avatar_path")
        .eq("phone", phone)
        .maybeSingle();
    if (!findErr && usersByPhone) {
        return {
            userId: usersByPhone.user_id,
            name: usersByPhone.name,
            phone: usersByPhone.phone,
            email: usersByPhone.email ?? undefined,
            address: usersByPhone.address,
            notifications: usersByPhone.notifications,
            languageCode: usersByPhone.language_code,
            avatarPath: usersByPhone.avatar_path ?? undefined,
        };
    }
    // Create one
    const digits = phone.replace(/\D/g, "");
    const userId = `u_${digits || Math.random().toString(36).slice(2)}`;
    const { data: created, error: insertErr } = await supabase_1.supabase
        .from("users")
        .insert({
        user_id: userId,
        name: "User",
        phone,
        address: "ул. Пушкина 15",
        notifications: true,
        language_code: "ru",
    })
        .select("user_id,name,phone,email,address,notifications,language_code,avatar_path")
        .single();
    if (insertErr || !created) {
        // fallback local
        return (0, db_1.ensureUserByPhone)(phone);
    }
    return {
        userId: created.user_id,
        name: created.name,
        phone: created.phone,
        email: created.email ?? undefined,
        address: created.address,
        notifications: created.notifications,
        languageCode: created.language_code,
        avatarPath: created.avatar_path ?? undefined,
    };
}
function sendOtp(phone) {
    const normalized = phone.trim();
    const code = process.env.DEMO_OTP_CODE || "1234";
    db_1.db.otps.set(normalized, code);
    // In real world, integrate SMS provider here
    (0, db_1.ensureUserByPhone)(normalized);
    return true;
}
async function verifyOtp(phone, code) {
    const normalized = phone.trim();
    const expected = db_1.db.otps.get(normalized);
    if (!expected || expected !== code) {
        return null;
    }
    const profile = await ensureSupabaseUserByPhone(normalized);
    const token = (0, jwt_1.signAuthToken)({ userId: profile.userId, phone: normalized });
    // one-time use
    db_1.db.otps.delete(normalized);
    return { token, user: profile };
}
//# sourceMappingURL=auth.service.js.map