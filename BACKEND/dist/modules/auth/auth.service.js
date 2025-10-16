"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendOtp = sendOtp;
exports.verifyOtp = verifyOtp;
const db_1 = require("../../core/config/db");
const jwt_1 = require("../../core/utils/jwt");
function sendOtp(phone) {
    const normalized = phone.trim();
    const code = process.env.DEMO_OTP_CODE || "1234";
    db_1.db.otps.set(normalized, code);
    // In real world, integrate SMS provider here
    (0, db_1.ensureUserByPhone)(normalized);
    return true;
}
function verifyOtp(phone, code) {
    const normalized = phone.trim();
    const expected = db_1.db.otps.get(normalized);
    if (!expected || expected !== code) {
        return null;
    }
    const profile = (0, db_1.ensureUserByPhone)(normalized);
    const token = (0, jwt_1.signAuthToken)({ userId: profile.userId, phone: profile.phone });
    // one-time use
    db_1.db.otps.delete(normalized);
    return { token, user: profile };
}
//# sourceMappingURL=auth.service.js.map