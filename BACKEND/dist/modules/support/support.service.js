"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.submitSupportMessage = submitSupportMessage;
const db_1 = require("../../core/config/db");
const supabase_1 = require("../../core/config/supabase");
async function submitSupportMessage(data) {
    const id = `s_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 6)}`;
    const createdAt = new Date().toISOString();
    const message = { id, createdAt, ...data };
    if (supabase_1.supabase) {
        const { error } = await supabase_1.supabase.from("support_messages").insert({
            id: message.id,
            user_id: message.userId ?? null,
            phone: message.phone ?? null,
            subject: message.subject,
            message: message.message,
            created_at: message.createdAt,
        });
        if (!error)
            return message;
    }
    db_1.db.supports.push(message);
    return message;
}
//# sourceMappingURL=support.service.js.map