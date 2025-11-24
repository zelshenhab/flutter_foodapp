// src/mobileApplication/services/payment.service.ts
import { iikoPaymentService } from "../../../core/iiko/iiko.payment.service";
import { supabase } from "../../../core/config/supabase";

class PaymentService {
  /** Begin payment process */
  async startPayment(orderId: number) {
    const order = await supabase
      .from("Order")
      .select("id, total")
      .eq("id", orderId)
      .single();

    if (order.error) throw order.error;

    const { paymentId, paymentUrl } = await iikoPaymentService.createPayment(
      orderId,
      order.data.total
    );

    // save paymentId in DB
    await supabase
      .from("Order")
      .update({ paymentId })
      .eq("id", orderId);

    return { paymentId, paymentUrl };
  }

  /** Webhook updates */
  async completePayment(paymentId: string, status: string) {
    await supabase
      .from("Order")
      .update({
        paymentStatus: status,
        status: status === "Paid" ? "completed" : "cancelled",
      })
      .eq("paymentId", paymentId);
  }
}

export const paymentService = new PaymentService();
