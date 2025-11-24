// src/mobileApplication/controllers/payment.controller.ts
import { Request, Response } from "express";
import { paymentService } from "../payment/payment.service";

export async function startPayment(req: Request, res: Response) {
  const orderId = Number(req.body.orderId);

  try {
    const data = await paymentService.startPayment(orderId);
    res.json({ success: true, data });
  } catch (e) {
    res.status(500).json({ success: false, error: String(e) });
  }
}
