"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.postSupport = postSupport;
const support_service_1 = require("./support.service");
function postSupport(req, res) {
    const body = req.body;
    if (!body?.subject || !body?.message) {
        return res.status(400).json({ message: "subject and message are required" });
    }
    const userId = req.user?.userId;
    const created = (0, support_service_1.submitSupportMessage)({ userId, phone: body.phone, subject: body.subject, message: body.message });
    return res.status(201).json(created);
}
//# sourceMappingURL=support.controller.js.map