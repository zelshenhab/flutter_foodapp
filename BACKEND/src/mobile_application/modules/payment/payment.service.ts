// src/dashboard/services/payment.service.ts

import { supabase } from "../../../core/config/supabase";
import { iikoClient } from "../../../core/iiko/iiko.client";

class PaymentService {
  private organizationId = "demo-org-987654321"; // replace later

  /** -----------------------------------------
   *  1) Create payment session in iiko
   * --------------------------------------- */
  async createPayment(orderId: number) {
    // 1) fetch order from DB
    const { data: order, error } = await supabase
      .from("Order")
      .select("*")
      .eq("id", orderId)
      .single();

    if (error || !order) {
      throw new Error("Order not found");
    }

    // 2) iiko create payment request
    const body = {
      organizationId: this.organizationId,
      paymentMethodType: "Card", // can be Card / SBP / etc.
      paymentType: "External",
      amount: Number(order.total),
      order: {
        id: orderId.toString(),
        externalNumber: "FOODAPP-" + orderId,
      },
      successUrl: "https://example.com/payment/success", // replace later
      failUrl: "https://example.com/payment/fail",
    };

    const result = await iikoClient.request(
      "POST",
      "/payment/create",
      body
    );

    if (!result.redirectUrl) {
      throw new Error("Failed to create payment session in iiko");
    }

    const paymentUrl = result.redirectUrl;
    const paymentId = result.paymentId ?? null;

    // 3) store paymentId in DB
    await supabase
      .from("Order")
      .update({
        paymentId,
        paymentStatus: "pending",
      })
      .eq("id", orderId);

    return { paymentUrl };
  }

  /** -----------------------------------------
   *  2) Check payment status (manual refresh)
   * --------------------------------------- */
  async checkPaymentStatus(orderId: number) {
    // 1) find order
    const { data: order, error } = await supabase
      .from("Order")
      .select("paymentId")
      .eq("id", orderId)
      .single();

    if (error || !order) throw new Error("Order not found");
    if (!order.paymentId) throw new Error("Order has no payment session");

    // 2) request status from iiko
    const result = await iikoClient.request(
      "POST",
      "/payment/status",
      {
        organizationId: this.organizationId,
        paymentId: order.paymentId,
      }
    );

    const status = result.paymentStatus;

    // 3) update DB
    await supabase
      .from("Order")
      .update({
        paymentStatus: status,
        status: status === "Success" ? "completed" : "pending",
      })
      .eq("id", orderId);

    return status;
  }

  /** -----------------------------------------
   *  3) Webhook from iiko -> update order status
   * --------------------------------------- */
  async handleWebhook(event: any) {
    const paymentId = event?.paymentId;
    const status = event?.status;

    if (!paymentId) {
      console.warn("Webhook ignored — no paymentId");
      return;
    }

    // find order
    const { data: order } = await supabase
      .from("Order")
      .select("id")
      .eq("paymentId", paymentId)
      .single();

    if (!order) {
      console.warn("Webhook: Order not found");
      return;
    }

    // update order status
    await supabase
      .from("Order")
      .update({
        paymentStatus: status,
        status: status === "Success" ? "completed" : "cancelled",
      })
      .eq("id", order.id);

    console.log("⚡ Webhook processed for order", order.id);
  }
}

// export singleton
export const paymentService = new PaymentService();
