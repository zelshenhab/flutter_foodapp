"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.paymentService = void 0;
const supabase_1 = require("../../../core/config/supabase");
const yookassa_client_1 = require("../../../core/yookassa/yookassa.client");
class PaymentService {
    /**
     * Create YooKassa payment
     */
    async createPayment(orderId, userId) {
        const { data: order, error } = await supabase_1.supabase
            .from("Order")
            .select("*")
            .eq("id", orderId)
            .eq("userId", userId) // 🔐 important security check
            .single();
        if (error || !order) {
            throw new Error("Order not found");
        }
        const payment = await (0, yookassa_client_1.createPayment)(order.total, orderId);
        await supabase_1.supabase
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
    async markOrderPaid(paymentId) {
        const { data: order } = await supabase_1.supabase
            .from("Order")
            .select("*")
            .eq("yookassaPaymentId", paymentId)
            .single();
        if (!order)
            return;
        await supabase_1.supabase
            .from("Order")
            .update({
            paymentStatus: "Paid",
            status: "completed",
            paidAt: new Date().toISOString(),
        })
            .eq("id", order.id);
    }
}
exports.paymentService = new PaymentService();
//# sourceMappingURL=payment.service.js.map