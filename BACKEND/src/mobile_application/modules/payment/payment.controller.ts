// src/dashboard/controllers/payment.controller.ts

import { Request, Response, NextFunction } from "express";
import { paymentService } from "../payment/payment.service";

export class PaymentController {

  /** -----------------------------------------
   *  1) Create payment session
   * ---------------------------------------- */
  static async createPayment(req: Request, res: Response, next: NextFunction) {
    try {
      const { orderId } = req.body;

      if (!orderId) {
        return res.status(400).json({ error: "orderId is required" });
      }

      const result = await paymentService.createPayment(orderId);

      return res.json({
        success: true,
        paymentUrl: result.paymentUrl,
      });

    } catch (err) {
      console.error("❌ CREATE PAYMENT ERROR:", err);
      next(err);
    }
  }

  /** -----------------------------------------
   *  2) Check payment status
   * ---------------------------------------- */
  static async checkStatus(req: Request, res: Response, next: NextFunction) {
    try {
      const orderId = Number(req.params.id);

      if (!orderId) {
        return res.status(400).json({ error: "Invalid order id" });
      }

      const status = await paymentService.checkPaymentStatus(orderId);

      return res.json({
        success: true,
        status,
      });

    } catch (err) {
      console.error("❌ CHECK PAYMENT STATUS ERROR:", err);
      next(err);
    }
  }

  /** -----------------------------------------
   *  3) Webhook (iiko sends updates)
   * ---------------------------------------- */
  static async webhook(req: Request, res: Response, next: NextFunction) {
    try {
      const event = req.body;

      console.log("📩 IIKO WEBHOOK RECEIVED:", event);

      await paymentService.handleWebhook(event);

      return res.json({ received: true });

    } catch (err) {
      console.error("❌ IIKO WEBHOOK ERROR:", err);
      next(err);
    }
  }
}
