// mobile_application/modules/payment/payment.service.ts
import { supabase } from "../../../core/config/supabase";
import { iikoClient } from "../../../core/iiko/iiko.client";
import { IIKO_ORGANIZATION_ID } from "../../../core/iiko/iiko.constants";

const ONLINE_PAYMENT_TYPE_ID =
  "fc1aee25-7275-4bb6-9d0a-3213ee876eed"; // ONLN

class PaymentService {

  /**
   * Register external payment in iiko
   */
  async registerPaymentInIiko(orderId: number) {
    const { data: order, error } = await supabase
      .from("Order")
      .select("*")
      .eq("id", orderId)
      .single();

    if (error || !order) {
      throw new Error("Order not found");
    }

    if (order.iikoOrderId == null) {
      throw new Error("Order not sent to iiko");
    }

    const body = {
      organizationId: IIKO_ORGANIZATION_ID,
      orderId: order.iikoOrderId, // UUID from iiko
      payments: [
        {
          paymentTypeId: ONLINE_PAYMENT_TYPE_ID,
          paymentTypeKind: "Card",
          sum: Math.round(order.total),
          isProcessedExternally: true,
          isFiscalizedExternally: true,
          isPrepay: true,
        },
      ],
    };

    await iikoClient.request(
      "POST",
      "/order/add_payments",
      body
    );

    await supabase
      .from("Order")
      .update({
        paymentStatus: "Paid",
        status: "completed",
      })
      .eq("id", orderId);
  }
}

export const paymentService = new PaymentService();
