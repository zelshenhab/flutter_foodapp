import { supabase } from "../../../core/config/supabase";
import { createPayment } from "../../../core/yookassa/yookassa.client";

class PaymentService {

  /**
   * Create YooKassa payment
   */
  async createPayment(orderId: number, userId: number) {

    const { data: order, error } = await supabase
      .from("Order")
      .select("*")
      .eq("id", orderId)
      .eq("userId", userId)   // 🔐 important security check
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

    return payment.confirmation.confirmation_url;
  }

  /**
   * Called when payment confirmed
   */
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