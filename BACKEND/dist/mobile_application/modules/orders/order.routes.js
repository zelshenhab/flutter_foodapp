"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.orderRouter = void 0;
const express_1 = require("express");
const order_controller_1 = require("./order.controller");
exports.orderRouter = (0, express_1.Router)();
// New (Phase 4)
exports.orderRouter.get("/", order_controller_1.listMyOrders);
exports.orderRouter.put("/:id/complete", order_controller_1.completeOrder); // ✅ NEW  // GET /api/orders?status=pending&page=1&limit=10
exports.orderRouter.get("/:id", order_controller_1.getMyOrder); // GET /api/orders/123
// Existing (Phase 3)
exports.orderRouter.post("/preview", order_controller_1.previewOrder);
exports.orderRouter.post("/", order_controller_1.createOrder);
//# sourceMappingURL=order.routes.js.map