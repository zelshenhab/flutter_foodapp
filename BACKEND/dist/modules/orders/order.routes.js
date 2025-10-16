"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_middleware_1 = require("../../core/middlewares/auth.middleware");
const order_controller_1 = require("./order.controller");
const router = (0, express_1.Router)();
router.get("/", auth_middleware_1.requireAuth, order_controller_1.getOrders);
router.get("/:orderId", auth_middleware_1.requireAuth, order_controller_1.getOrder);
router.post("/", auth_middleware_1.requireAuth, order_controller_1.postOrder);
exports.default = router;
//# sourceMappingURL=order.routes.js.map