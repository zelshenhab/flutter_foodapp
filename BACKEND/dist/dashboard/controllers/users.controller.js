"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getUsers = getUsers;
exports.getUser = getUser;
exports.blockUserController = blockUserController;
exports.unblockUserController = unblockUserController;
exports.updateRoleController = updateRoleController;
const users_service_1 = require("../services/users.service");
async function getUsers(req, res) {
    try {
        const page = Number(req.query.page) || 1;
        const limit = Number(req.query.limit) || 20;
        const offset = (page - 1) * limit;
        const users = await (0, users_service_1.fetchUsers)(limit, offset);
        const total = await (0, users_service_1.countUsers)();
        return res.json({
            data: users,
            page,
            limit,
            total,
            totalPages: Math.ceil(total / limit)
        });
    }
    catch (e) {
        console.error("GET USERS ERROR:", e);
        return res.status(500).json({ error: "Failed to fetch users" });
    }
}
async function getUser(req, res) {
    try {
        const user = await (0, users_service_1.fetchUser)(Number(req.params.id));
        return res.json({ data: user });
    }
    catch (e) {
        console.error("GET USER ERROR:", e);
        return res.status(500).json({ error: "Failed to fetch user" });
    }
}
async function blockUserController(req, res) {
    try {
        console.log('🛑 BLOCK USER CONTROLLER - START');
        const userId = Number(req.params.id);
        const result = await (0, users_service_1.blockUser)(userId);
        console.log('✅ BLOCK USER CONTROLLER - SUCCESS:', result);
        return res.json({ success: true });
    }
    catch (e) {
        console.error("❌ BLOCK USER CONTROLLER - CAUGHT ERROR:", e);
        // Don't modify the error, let it pass through to errorHandler
        throw e;
    }
}
async function unblockUserController(req, res) {
    try {
        await (0, users_service_1.unblockUser)(Number(req.params.id));
        return res.json({ success: true });
    }
    catch (e) {
        console.error("UNBLOCK USER ERROR:", e);
        return res.status(500).json({ error: "Failed to unblock user" });
    }
}
async function updateRoleController(req, res) {
    try {
        const { role } = req.body;
        await (0, users_service_1.updateUserRole)(Number(req.params.id), role);
        return res.json({ success: true });
    }
    catch (e) {
        console.error("UPDATE ROLE ERROR:", e);
        return res.status(500).json({ error: "Failed to update role" });
    }
}
//# sourceMappingURL=users.controller.js.map