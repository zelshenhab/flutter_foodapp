import { supabase } from "../../../core/config/supabase";
import {
  createPayment,
  getPayment,
} from "../../../core/yookassa/yookassa.client";

class PaymentService {
  /// 🔹 CREATE PAYMENT
  async createPayment(orderId: number, userId: number) {
    const { data: order, error } = await supabase
      .from("Order")
      .select("*")
      .eq("id", orderId)
      .eq("userId", userId)
      .single();

    if (error || !order) {
      throw new Error("Order not found");
    }

    const payment = await createPayment(order.total, orderId);

    await supabase
      .from("Order")
      .update({
        paymentStatus: "Pending",
        yookassaPaymentId: payment.id,
      })
      .eq("id", orderId);

    return {
      paymentId: payment.id,
      confirmationUrl: payment.confirmation.confirmation_url,
    };
  }

  /// 🔥 CHECK PAYMENT STATUS (REAL SOURCE OF TRUTH)
  async getPaymentStatus(paymentId: string) {
    const payment = await getPayment(paymentId);

    return payment.status; // pending | succeeded | canceled
  }

  /// 🔥 MARK ORDER PAID (used by webhook)
  async markOrderPaid(paymentId: string) {
    const { data: order } = await supabase
      .from("Order")
      .select("*")
      .eq("yookassaPaymentId", paymentId)
      .single();

    if (!order) return;

    await supabase
      .from("Order")
      .update({
        paymentStatus: "Paid",
        status: "completed",
        paidAt: new Date().toISOString(),
      })
      .eq("id", order.id);
  }
}

export const paymentService = new PaymentService();