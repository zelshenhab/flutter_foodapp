"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.fetchUsers = fetchUsers;
exports.countUsers = countUsers;
exports.fetchUser = fetchUser;
exports.blockUser = blockUser;
exports.unblockUser = unblockUser;
exports.updateUserRole = updateUserRole;
const supabase_1 = require("../../core/config/supabase");
const USER_TABLE = "User";
// Fetch all users
async function fetchUsers(limit, offset) {
    const { data, error } = await supabase_1.supabase
        .from(USER_TABLE)
        .select("id, name, email, avatarUrl, role, blocked, createdAt")
        .order("createdAt", { ascending: false })
        .range(offset, offset + limit - 1);
    if (error)
        throw error;
    return data;
}
async function countUsers() {
    const { count, error } = await supabase_1.supabase
        .from(USER_TABLE)
        .select("*", { count: "exact", head: true });
    if (error)
        throw error;
    return count ?? 0;
}
// Get one user
async function fetchUser(id) {
    const { data, error } = await supabase_1.supabase
        .from(USER_TABLE)
        .select("*")
        .eq("id", id)
        .maybeSingle();
    if (error)
        throw error;
    return data ? data : null;
}
// Block user
// Block user
async function blockUser(id) {
    try {
        console.log('🛑 Attempting to block user:', id);
        const { data, error } = await supabase_1.supabase
            .from(USER_TABLE)
            .update({ blocked: true })
            .eq("id", id)
            .select();
        console.log('🔧 Block user response:', { data, error });
        if (error) {
            console.error('❌ Supabase error blocking user:', {
                message: error.message,
                details: error.details,
                hint: error.hint,
                code: error.code
            });
            throw error;
        }
        console.log('✅ User blocked successfully');
        return true;
    }
    catch (error) {
        console.error('❌ BLOCK USER SERVICE ERROR:', error);
        throw error; // Re-throw so error handler can see it
    }
}
// Unblock user
async function unblockUser(id) {
    const { error } = await supabase_1.supabase
        .from(USER_TABLE)
        .update({ blocked: false })
        .eq("id", id);
    if (error)
        throw error;
    return true;
}
// Update role
async function updateUserRole(id, role) {
    const { error } = await supabase_1.supabase
        .from(USER_TABLE)
        .update({ role })
        .eq("id", id);
    if (error)
        throw error;
    return true;
}
//# sourceMappingURL=users.service.js.map