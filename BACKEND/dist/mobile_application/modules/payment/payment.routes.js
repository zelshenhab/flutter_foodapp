"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.paymentRouter = void 0;
const express_1 = require("express");
const payment_controller_1 = require("./payment.controller");
const auth_middleware_1 = require("../../../core/middlewares/auth.middleware");
exports.paymentRouter = (0, express_1.Router)();
exports.paymentRouter.post("/create", auth_middleware_1.requireAuth, payment_controller_1.PaymentController.createPayment);
exports.paymentRouter.post("/webhook", payment_controller_1.PaymentController.webhook);
//# sourceMappingURL=payment.routes.js.map