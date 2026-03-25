"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authRouter = void 0;
const express_1 = require("express");
const auth_controller_1 = require("./auth.controller");
exports.authRouter = (0, express_1.Router)();
exports.authRouter.post("/otp/request", auth_controller_1.requestOtp);
exports.authRouter.post("/otp/verify", auth_controller_1.verifyOtp);
exports.authRouter.post("/refresh", auth_controller_1.postRefresh);
exports.authRouter.post("/logout", auth_controller_1.logout);
exports.authRouter.delete("/delete-account", auth_controller_1.deleteAccount);
exports.authRouter.get("/me", auth_controller_1.getMe);
//# sourceMappingURL=auth.routes.js.map