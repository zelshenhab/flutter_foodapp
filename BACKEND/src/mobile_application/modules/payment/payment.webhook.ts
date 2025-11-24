// src/mobileApplication/controllers/payment.webhook.ts
import { Request, Response } from "express";
import { paymentService } from "../payment/payment.service";

export async function iikoWebhook(req: Request, res: Response) {
  const { paymentId, status } = req.body;

  await paymentService.completePayment(paymentId, status);

  res.json({ received: true });
}
