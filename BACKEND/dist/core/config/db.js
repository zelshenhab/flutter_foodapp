"use strict";
// Simple in-memory data store for demo purposes. Replace with real DB later.
Object.defineProperty(exports, "__esModule", { value: true });
exports.db = void 0;
exports.ensureUserByPhone = ensureUserByPhone;
exports.db = {
    users: new Map(),
    otps: new Map(),
    orders: new Map(),
    supports: [],
};
function ensureUserByPhone(phone) {
    // derive a deterministic userId from phone for demo
    const userId = `u_${phone.replace(/\D/g, "") || Math.random().toString(36).slice(2)}`;
    const existing = exports.db.users.get(userId);
    if (existing)
        return existing;
    const profile = {
        userId,
        name: "User",
        phone,
        address: "ул. Пушкина 15",
        notifications: true,
        languageCode: "ru",
    };
    exports.db.users.set(userId, profile);
    if (!exports.db.orders.has(userId))
        exports.db.orders.set(userId, []);
    return profile;
}
//# sourceMappingURL=db.js.map