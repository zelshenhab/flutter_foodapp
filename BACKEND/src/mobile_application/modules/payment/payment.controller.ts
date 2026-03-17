import { Request, Response, NextFunction } from "express";
import { paymentService } from "./payment.service";

export class PaymentController {

  static async createPayment(
    req: Request,
    res: Response,
    next: NextFunction
  ) {
    try {

      console.log("====== CREATE PAYMENT ======");
      console.log("HEADERS:", req.headers);
      console.log("BODY:", req.body);
      console.log("USER:", (req as any).user);

      const userId = (req as any).user?.id;

      if (!userId) {
        console.log("❌ USER NOT AUTHENTICATED");
        return res.status(401).json({ error: "Unauthorized" });
      }

      const { orderId } = req.body;

      if (!orderId) {
        console.log("❌ orderId missing");
        return res.status(400).json({ error: "orderId required" });
      }

      console.log("Creating payment for order:", orderId);
      console.log("User:", userId);

      const url = await paymentService.createPayment(orderId, userId);

      console.log("✅ Payment created:", url);

      res.json({
        confirmationUrl: url,
      });

    } catch (e) {
      console.error("❌ PAYMENT ERROR:", e);
      next(e);
    }
  }

  static async webhook(req: Request, res: Response) {

    console.log("====== YOOKASSA WEBHOOK ======");
    console.log("EVENT:", req.body);

    const event = req.body;

    if (event.object?.status === "succeeded") {

      const paymentId = event.object.id;

      console.log("Payment succeeded:", paymentId);

      await paymentService.markOrderPaid(paymentId);
    }

    res.json({ ok: true });
  }
}