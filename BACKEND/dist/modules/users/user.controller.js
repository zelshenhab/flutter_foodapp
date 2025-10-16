"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getMe = getMe;
exports.patchMe = patchMe;
const user_service_1 = require("./user.service");
async function getMe(req, res) {
    const userId = req.user.userId;
    const profile = await (0, user_service_1.getUserProfile)(userId);
    if (!profile)
        return res.status(404).json({ message: "User not found" });
    return res.json(profile);
}
async function patchMe(req, res) {
    const userId = req.user.userId;
    const body = req.body;
    const updated = await (0, user_service_1.updateUserProfile)(userId, body);
    if (!updated)
        return res.status(404).json({ message: "User not found" });
    return res.json(updated);
}
//# sourceMappingURL=user.controller.js.map