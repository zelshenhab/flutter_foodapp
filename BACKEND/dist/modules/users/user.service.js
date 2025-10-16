"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getUserProfile = getUserProfile;
exports.updateUserProfile = updateUserProfile;
const db_1 = require("../../core/config/db");
const supabase_1 = require("../../core/config/supabase");
async function getUserProfile(userId) {
    if (supabase_1.supabase) {
        const { data, error } = await supabase_1.supabase
            .from("users")
            .select("user_id,name,phone,email,address,notifications,language_code,avatar_path")
            .eq("user_id", userId)
            .maybeSingle();
        if (!error && data) {
            return {
                userId: data.user_id,
                name: data.name,
                phone: data.phone,
                email: data.email ?? undefined,
                address: data.address,
                notifications: data.notifications,
                languageCode: data.language_code,
                avatarPath: data.avatar_path ?? undefined,
            };
        }
    }
    return db_1.db.users.get(userId) ?? null;
}
async function updateUserProfile(userId, updates) {
    if (supabase_1.supabase) {
        const payload = {
            name: updates.name,
            email: updates.email,
            address: updates.address,
            notifications: updates.notifications,
            language_code: updates.languageCode,
            avatar_path: updates.avatarPath,
        };
        Object.keys(payload).forEach((k) => payload[k] === undefined && delete payload[k]);
        const { data, error } = await supabase_1.supabase
            .from("users")
            .update(payload)
            .eq("user_id", userId)
            .select("user_id,name,phone,email,address,notifications,language_code,avatar_path")
            .single();
        if (!error && data) {
            return {
                userId: data.user_id,
                name: data.name,
                phone: data.phone,
                email: data.email ?? undefined,
                address: data.address,
                notifications: data.notifications,
                languageCode: data.language_code,
                avatarPath: data.avatar_path ?? undefined,
            };
        }
    }
    const current = db_1.db.users.get(userId);
    if (!current)
        return null;
    const next = { ...current, ...updates };
    db_1.db.users.set(userId, next);
    return next;
}
//# sourceMappingURL=user.service.js.map