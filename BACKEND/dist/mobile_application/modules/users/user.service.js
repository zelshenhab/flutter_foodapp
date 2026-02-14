"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getMe = getMe;
exports.updateMe = updateMe;
const supabase_1 = require("../../../core/config/supabase");
async function getMe(userId) {
    const { data, error } = await supabase_1.supabase
        .from("User")
        .select("id, email, name, avatarUrl, createdAt")
        .eq("id", userId)
        .single();
    if (error || !data)
        throw { status: 404, message: "User not found" };
    return data;
}
async function updateMe(userId, patch) {
    if (Object.keys(patch).length === 0)
        return getMe(userId);
    const { data, error } = await supabase_1.supabase
        .from("User")
        .update(patch)
        .eq("id", userId)
        .select("id, email, name, avatarUrl, createdAt")
        .single();
    if (error || !data)
        throw { status: 500, message: "Profile update failed" };
    return data;
}
//# sourceMappingURL=user.service.js.map