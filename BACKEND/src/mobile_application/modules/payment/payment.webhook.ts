// src/mobile_application/controllers/payment.webhook.ts

import { Request, Response } from "express";
import { paymentService } from "../payment/payment.service";

/**
 * Handles callbacks from iiko Cloud payment notifications.
 * iiko will keep retrying until your backend returns 200 OK.
 */
export async function iikoWebhook(req: Request, res: Response) {
  try {
    const event = req.body;

    console.log("🔔 Received iiko webhook:", JSON.stringify(event, null, 2));

    // Validate minimal data expected from iiko
    if (!event || !event.paymentId) {
      console.warn("⚠ Received invalid webhook:", event);
      // Still return 200 or iiko will retry
      return res.json({ ok: true });
    }

    // Process webhook inside service
    await paymentService.handleWebhook(event);

    // Respond 200 NO MATTER WHAT (iiko requirement)
    return res.json({ ok: true });
  } catch (e) {
    console.error("❌ Webhook error:", e);
    // Still return OK — otherwise iiko retries every 10 seconds
    return res.json({ ok: true });
  }
}
