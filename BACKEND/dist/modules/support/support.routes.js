"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const support_controller_1 = require("./support.controller");
const auth_middleware_1 = require("../../core/middlewares/auth.middleware");
const router = (0, express_1.Router)();
// Accept support with or without auth
router.post("/", auth_middleware_1.optionalAuth, support_controller_1.postSupport);
exports.default = router;
//# sourceMappingURL=support.routes.js.map