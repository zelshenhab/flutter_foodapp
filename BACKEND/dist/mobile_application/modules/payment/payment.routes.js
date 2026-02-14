"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.paymentRouter = void 0;
// mobile_application/modules/payment/payment.routes.ts
const express_1 = require("express");
const payment_controller_1 = require("./payment.controller");
exports.paymentRouter = (0, express_1.Router)();
/**
 * User confirms payment success (after SBP / bank)
 */
exports.paymentRouter.post("/confirm", payment_controller_1.PaymentController.confirmPayment);
/**
 * Optional: webhook from external payment provider (later)
 */
exports.paymentRouter.post("/webhook", payment_controller_1.PaymentController.webhook);
//# sourceMappingURL=payment.routes.js.map