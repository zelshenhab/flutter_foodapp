// mobile_application/modules/payment/payment.routes.ts
import { Router } from "express";
import { PaymentController } from "./payment.controller";

export const paymentRouter = Router();

/**
 * User confirms payment success (after SBP / bank)
 */
paymentRouter.post("/confirm", PaymentController.confirmPayment);

/**
 * Optional: webhook from external payment provider (later)
 */
paymentRouter.post("/webhook", PaymentController.webhook);
