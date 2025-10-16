"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getUserProfile = getUserProfile;
exports.updateUserProfile = updateUserProfile;
const db_1 = require("../../core/config/db");
function getUserProfile(userId) {
    return db_1.db.users.get(userId) ?? null;
}
function updateUserProfile(userId, updates) {
    const current = db_1.db.users.get(userId);
    if (!current)
        return null;
    const next = { ...current, ...updates };
    db_1.db.users.set(userId, next);
    return next;
}
//# sourceMappingURL=user.service.js.map