"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.submitSupportMessage = submitSupportMessage;
const db_1 = require("../../core/config/db");
function submitSupportMessage(data) {
    const id = `s_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 6)}`;
    const createdAt = new Date().toISOString();
    const message = { id, createdAt, ...data };
    db_1.db.supports.push(message);
    return message;
}
//# sourceMappingURL=support.service.js.map