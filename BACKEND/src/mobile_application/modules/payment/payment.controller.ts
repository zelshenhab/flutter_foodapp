import { Request, Response, NextFunction } from "express";
import { paymentService } from "./payment.service";

export class PaymentController {
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

      const result = await paymentService.createPayment(Number(orderId), userId);

      return res.json(result);
    } catch (e) {
      console.error("❌ PAYMENT ERROR:", e);
      next(e);
    }
  }

  static async getStatus(req: Request, res: Response) {
    try {
      const { paymentId } = req.params;

      if (!paymentId) {
        return res.status(400).json({ error: "paymentId required" });
      }

      const status = await paymentService.syncOrderWithPayment(paymentId);

      return res.json({ status });
    } catch (e) {
      console.error("❌ STATUS ERROR:", e);
      return res.status(500).json({ error: "Failed to get payment status" });
    }
  }

  static async webhook(req: Request, res: Response) {
    try {
      console.log("====== YOOKASSA WEBHOOK ======");
      console.log("EVENT:", req.body);

      const event = req.body;

      if (event.object?.id) {
        const paymentId = event.object.id;
        await paymentService.syncOrderWithPayment(paymentId);
      }

      return res.json({ ok: true });
    } catch (e) {
      console.error("❌ WEBHOOK ERROR:", e);
      return res.status(500).json({ ok: false });
    }
  }
}