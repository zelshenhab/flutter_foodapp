"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_controller_1 = require("./auth.controller");
const router = (0, express_1.Router)();
router.post("/send-otp", auth_controller_1.postSendOtp);
router.post("/verify-otp", auth_controller_1.postVerifyOtp);
exports.default = router;
//# sourceMappingURL=auth.routes.js.map