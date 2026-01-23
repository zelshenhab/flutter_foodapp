// mobile_application/modules/payment/payment.controller.ts
import { Request, Response, NextFunction } from "express";
import { paymentService } from "./payment.service";

export class PaymentController {

  /**
   * Called AFTER external payment success
   */
  static async confirmPayment(
    req: Request,
    res: Response,
    next: NextFunction
  ) {
    try {
      const { orderId } = req.body;

      if (!orderId) {
        return res.status(400).json({ error: "orderId required" });
      }

      await paymentService.registerPaymentInIiko(orderId);

      res.json({ success: true });
    } catch (e) {
      next(e);
    }
  }

  static async webhook(req: Request, res: Response) {
    // future SBP provider webhook
    res.json({ ok: true });
  }
}
