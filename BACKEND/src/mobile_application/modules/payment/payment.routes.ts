// src/mobileApplication/routes/payment.routes.ts
import { Router } from "express";
import { startPayment } from "../payment/payment.controller";
import { iikoWebhook } from "../payment/payment.webhook";

export const paymentRouter = Router();

paymentRouter.post("/start", startPayment);
paymentRouter.post("/webhook/iiko", iikoWebhook);
