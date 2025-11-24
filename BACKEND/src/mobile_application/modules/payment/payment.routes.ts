// src/mobile_application/routes/payment.routes.ts

import { Router } from "express";
import { paymentService } from "./payment.service";

export const paymentRouter = Router();

/* -------------------------------------------------------
 * 1) Create payment link for an order
 * ----------------------------------------------------- */
paymentRouter.post("/:orderId", async (req, res) => {
  try {
    const orderId = Number(req.params.orderId);

    if (!orderId) {
      return res.status(400).json({ error: "Invalid orderId" });
    }

    const result = await paymentService.createPayment(orderId);

    return res.json({
      success: true,
      paymentUrl: result.paymentUrl,
    });
  } catch (e: any) {
    console.error("Payment create error:", e);
    return res.status(500).json({
      success: false,
      error: e.message || "Internal server error",
    });
  }
});

/* -------------------------------------------------------
 * 2) Check payment status manually
 * ----------------------------------------------------- */
paymentRouter.get("/:orderId/status", async (req, res) => {
  try {
    const orderId = Number(req.params.orderId);

    if (!orderId) {
      return res.status(400).json({ error: "Invalid orderId" });
    }

    const status = await paymentService.checkPaymentStatus(orderId);

    return res.json({
      success: true,
      status,
    });
  } catch (e: any) {
    console.error("Payment status error:", e);
    return res.status(500).json({
      success: false,
      error: e.message || "Internal server error",
    });
  }
});

/* -------------------------------------------------------
 * 3) Webhook from iikoCloud
 * ----------------------------------------------------- */
paymentRouter.post("/webhook", async (req, res) => {
  try {
    const event = req.body;

    console.log("🔔 Received iiko webhook:", event);

    await paymentService.handleWebhook(event);

    // MUST reply 200 OK or iiko retries the webhook
    return res.json({ ok: true });
  } catch (e) {
    console.error("Webhook error:", e);
    return res.status(200).json({ ok: true }); 
    // Always 200 → iiko won't spam retries
  }
});
