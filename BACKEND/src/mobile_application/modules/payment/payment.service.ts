import { supabase } from "../../../core/config/supabase";
import { iikoClient } from "../../../core/iiko/iiko.client";
import { IIKO_ORGANIZATION_ID } from "../../../core/iiko/iiko.constants";

const ONLINE_PAYMENT_TYPE_ID = "fc1aee25-7275-4bb6-9d0a-3213ee876eed"; // ONLN

class PaymentService {
  /**
   * Handle webhook events from iiko
   */
  async handleWebhook(event: any) {
    console.log("🔔 Processing iiko webhook event:", event);

    try {
      // Extract relevant data from webhook
      const { paymentId, orderId, status, transactionId, timestamp } = event;

      // Log the webhook for debugging
      console.log(`Webhook received for payment: ${paymentId}, order: ${orderId}, status: ${status}`);

      // Handle different webhook events
      switch (status?.toLowerCase()) {
        case "success":
        case "completed":
          await this.handlePaymentSuccess(event);
          break;
        
        case "failed":
        case "declined":
          await this.handlePaymentFailed(event);
          break;
        
        case "refunded":
          await this.handlePaymentRefunded(event);
          break;
        
        default:
          console.log(`Unknown webhook status: ${status}`);
          // You might want to update order status to "pending" or similar
          await this.updateOrderStatus(orderId, "pending", event);
      }

    } catch (error) {
      console.error("Error processing webhook:", error);
      throw error; // This will be caught by the webhook handler
    }
  }

  /**
   * Handle successful payment
   */
  private async handlePaymentSuccess(event: any) {
    const { paymentId, orderId, transactionId, amount } = event;
    
    console.log(`✅ Payment successful: ${paymentId} for order ${orderId}`);
    
    // Update order status in your database
    const { error } = await supabase
      .from("Order")
      .update({
        paymentStatus: "Paid",
        status: "completed",
        iikoPaymentId: paymentId,
        iikoTransactionId: transactionId,
        paidAt: new Date().toISOString()
      })
      .eq("iikoOrderId", orderId); // Assuming orderId here is iikoOrderId

    if (error) {
      console.error("Error updating order status:", error);
      throw error;
    }

    console.log(`Order ${orderId} marked as paid`);
  }

  /**
   * Handle failed payment
   */
  private async handlePaymentFailed(event: any) {
    const { paymentId, orderId, reason } = event;
    
    console.log(`❌ Payment failed: ${paymentId} for order ${orderId}, reason: ${reason}`);
    
    // Update order status in your database
    const { error } = await supabase
      .from("Order")
      .update({
        paymentStatus: "Failed",
        status: "cancelled",
        iikoPaymentId: paymentId,
        cancellationReason: reason || "Payment failed"
      })
      .eq("iikoOrderId", orderId);

    if (error) {
      console.error("Error updating failed order status:", error);
      throw error;
    }

    console.log(`Order ${orderId} marked as failed`);
  }

  /**
   * Handle payment refund
   */
  private async handlePaymentRefunded(event: any) {
    const { paymentId, orderId, refundAmount } = event;
    
    console.log(`↩️ Payment refunded: ${paymentId} for order ${orderId}, amount: ${refundAmount}`);
    
    // Update order status in your database
    const { error } = await supabase
      .from("Order")
      .update({
        paymentStatus: "Refunded",
        status: "refunded",
        iikoPaymentId: paymentId,
        refundedAt: new Date().toISOString(),
        refundAmount: refundAmount
      })
      .eq("iikoOrderId", orderId);

    if (error) {
      console.error("Error updating refunded order status:", error);
      throw error;
    }

    console.log(`Order ${orderId} marked as refunded`);
  }

  /**
   * Generic order status update
   */
  private async updateOrderStatus(orderId: string, status: string, event: any) {
    const { error } = await supabase
      .from("Order")
      .update({
        paymentStatus: status,
        status: status,
        iikoPaymentId: event.paymentId,
        iikoTransactionId: event.transactionId
      })
      .eq("iikoOrderId", orderId);

    if (error) {
      console.error(`Error updating order to ${status}:`, error);
      throw error;
    }
  }

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

    await iikoClient.request("POST", "/order/add_payments", body);

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