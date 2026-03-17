import { Router } from "express";
import { PaymentController } from "./payment.controller";
import { requireAuth } from "../../../core/middlewares/auth.middleware";


export const paymentRouter = Router();

paymentRouter.post("/create", requireAuth, PaymentController.createPayment);
paymentRouter.post("/webhook", PaymentController.webhook);