import { supabase } from "../../../core/config/supabase";
import {
  createPayment,
  getPayment,
} from "../../../core/yookassa/yookassa.client";

class PaymentService {
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

    const payment = await createPayment(Number(order.total), orderId);

    await supabase
      .from("Order")
      .update({
        paymentStatus: "Pending",
        yookassaPaymentId: payment.id,
        paymentProvider: "yookassa",
      })
      .eq("id", orderId);

    return {
      paymentId: payment.id,
      confirmationUrl: payment.confirmation.confirmation_url,
    };
  }

  async getPaymentStatus(paymentId: string) {
    const payment = await getPayment(paymentId);
    return payment.status as string; // pending | succeeded | canceled
  }

  async syncOrderWithPayment(paymentId: string) {
    const payment = await getPayment(paymentId);

    const { data: order, error } = await supabase
      .from("Order")
      .select("*")
      .eq("yookassaPaymentId", paymentId)
      .single();

    if (error || !order) {
      throw new Error("Order not found for payment");
    }

    if (payment.status === "succeeded") {
      await supabase
        .from("Order")
        .update({
          paymentStatus: "Paid",
          paidAt: new Date().toISOString(),
          status: order.status === "completed" ? order.status : "pending",
        })
        .eq("id", order.id);
    } else if (payment.status === "canceled") {
      await supabase
        .from("Order")
        .update({
          paymentStatus: "Cancelled",
        })
        .eq("id", order.id);
    } else {
      await supabase
        .from("Order")
        .update({
          paymentStatus: "Pending",
        })
        .eq("id", order.id);
    }

    return payment.status as string;
  }

  async markOrderPaid(paymentId: string) {
    const { data: order, error } = await supabase
      .from("Order")
      .select("*")
      .eq("yookassaPaymentId", paymentId)
      .single();

    if (error || !order) return;

    await supabase
      .from("Order")
      .update({
        paymentStatus: "Paid",
        paidAt: new Date().toISOString(),
        status: order.status === "completed" ? order.status : "pending",
      })
      .eq("id", order.id);
  }
}

export const paymentService = new PaymentService();