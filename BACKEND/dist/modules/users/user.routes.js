"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_middleware_1 = require("../../core/middlewares/auth.middleware");
const user_controller_1 = require("./user.controller");
const router = (0, express_1.Router)();
router.get("/me", auth_middleware_1.requireAuth, user_controller_1.getMe);
router.patch("/me", auth_middleware_1.requireAuth, user_controller_1.patchMe);
exports.default = router;
//# sourceMappingURL=user.routes.js.map