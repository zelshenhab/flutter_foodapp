"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.postSendOtp = postSendOtp;
exports.postVerifyOtp = postVerifyOtp;
const auth_service_1 = require("./auth.service");
function postSendOtp(req, res) {
    const body = req.body;
    if (!body?.phone)
        return res.status(400).json({ message: "phone is required" });
    const ok = (0, auth_service_1.sendOtp)(body.phone);
    return res.json({ success: ok });
}
function postVerifyOtp(req, res) {
    const body = req.body;
    if (!body?.phone || !body?.code) {
        return res.status(400).json({ message: "phone and code are required" });
    }
    const result = (0, auth_service_1.verifyOtp)(body.phone, body.code);
    if (!result)
        return res.status(401).json({ message: "Invalid code" });
    return res.json(result);
}
//# sourceMappingURL=auth.controller.js.map