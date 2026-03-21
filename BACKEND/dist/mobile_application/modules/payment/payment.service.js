"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.paymentService = void 0;
const supabase_1 = require("../../../core/config/supabase");
const yookassa_client_1 = require("../../../core/yookassa/yookassa.client");
class PaymentService {
    /// ================= CREATE PAYMENT =================
    async createPayment(orderId, userId) {
        ///  Get order
        const { data: order, error } = await supabase_1.supabase
            .from("Order")
            .select("*")
            .eq("id", orderId)
            .eq("userId", userId)
            .single();
        if (error || !order) {
            throw new Error("Order not found");
        }
        /// Get user email (REQUIRED for receipt)
        const { data: user } = await supabase_1.supabase
            .from("User")
            .select("email")
            .eq("id", userId)
            .single();
        const email = user?.email || "test@example.com";
        /// Build receipt items
        /// (for now: single item = whole order)
        const items = [
            {
                description: `Order #${orderId}`,
                quantity: "1.00",
                amount: {
                    value: Number(order.total).toFixed(2),
                    currency: "RUB",
                },
                vat_code: 1, // safe default
                /// REQUIRED
                payment_mode: "full_prepayment",
                payment_subject: "commodity",
            },
        ];
        /// Create YooKassa payment
        const payment = await (0, yookassa_client_1.createPayment)({
            amount: Number(order.total),
            orderId,
            email,
            items,
        });
        /// Save payment info
        await supabase_1.supabase
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
    /// ================= GET STATUS =================
    async getPaymentStatus(paymentId) {
        const payment = await (0, yookassa_client_1.getPayment)(paymentId);
        return payment.status;
    }
    /// ================= SYNC =================
    async syncOrderWithPayment(paymentId) {
        const payment = await (0, yookassa_client_1.getPayment)(paymentId);
        const { data: order, error } = await supabase_1.supabase
            .from("Order")
            .select("*")
            .eq("yookassaPaymentId", paymentId)
            .single();
        if (error || !order) {
            throw new Error("Order not found for payment");
        }
        if (payment.status === "succeeded") {
            await supabase_1.supabase
                .from("Order")
                .update({
                paymentStatus: "Paid",
                paidAt: new Date().toISOString(),
                status: order.status === "completed" ? order.status : "pending",
            })
                .eq("id", order.id);
        }
        else if (payment.status === "canceled") {
            await supabase_1.supabase
                .from("Order")
                .update({
                paymentStatus: "Cancelled",
            })
                .eq("id", order.id);
        }
        else {
            await supabase_1.supabase
                .from("Order")
                .update({
                paymentStatus: "Pending",
            })
                .eq("id", order.id);
        }
        return payment.status;
    }
    /// ================= WEBHOOK =================
    async markOrderPaid(paymentId) {
        const { data: order, error } = await supabase_1.supabase
            .from("Order")
            .select("*")
            .eq("yookassaPaymentId", paymentId)
            .single();
        if (error || !order)
            return;
        await supabase_1.supabase
            .from("Order")
            .update({
            paymentStatus: "Paid",
            paidAt: new Date().toISOString(),
            status: order.status === "completed" ? order.status : "pending",
        })
            .eq("id", order.id);
    }
}
exports.paymentService = new PaymentService();
//# sourceMappingURL=payment.service.js.map