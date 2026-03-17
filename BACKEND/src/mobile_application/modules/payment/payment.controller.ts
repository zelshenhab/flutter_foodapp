import { Request, Response, NextFunction } from "express";
import { paymentService } from "./payment.service";

export class PaymentController {
  /// 🔹 CREATE PAYMENT
  static async createPayment(
    req: Request,
    res: Response,
    next: NextFunction
  ) {
    try {
      const userId = (req as any).user?.id;

      if (!userId) {
        return res.status(401).json({ error: "Unauthorized" });
      }

      const { orderId } = req.body;

      if (!orderId) {
        return res.status(400).json({ error: "orderId required" });
      }

      const result = await paymentService.createPayment(orderId, userId);

      res.json(result); // 🔥 returns paymentId + confirmationUrl
    } catch (e) {
      console.error("❌ PAYMENT ERROR:", e);
      next(e);
    }
  }

  /// 🔥 GET PAYMENT STATUS
  static async getStatus(req: Request, res: Response) {
    try {
      const { paymentId } = req.params;

      if (!paymentId) {
        return res.status(400).json({ error: "paymentId required" });
      }

      const status = await paymentService.getPaymentStatus(paymentId);

      res.json({ status });
    } catch (e) {
      console.error("❌ STATUS ERROR:", e);
      res.status(500).json({ error: "Failed to get payment status" });
    }
  }

  /// 🔥 YOOKASSA WEBHOOK
  static async webhook(req: Request, res: Response) {
    try {
      console.log("====== YOOKASSA WEBHOOK ======");
      console.log("EVENT:", req.body);

      const event = req.body;

      if (event.object?.status === "succeeded") {
        const paymentId = event.object.id;

        console.log("✅ Payment succeeded:", paymentId);

        await paymentService.markOrderPaid(paymentId);
      }

      res.json({ ok: true });
    } catch (e) {
      console.error("❌ WEBHOOK ERROR:", e);
      res.status(500).json({ ok: false });
    }
  }
}