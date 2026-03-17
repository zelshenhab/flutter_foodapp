"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.paymentService = void 0;
const supabase_1 = require("../../../core/config/supabase");
const yookassa_client_1 = require("../../../core/yookassa/yookassa.client");
class PaymentService {
    async createPayment(orderId, userId) {
        const { data: order, error } = await supabase_1.supabase
            .from("Order")
            .select("*")
            .eq("id", orderId)
            .eq("userId", userId)
            .single();
        if (error || !order) {
            throw new Error("Order not found");
        }
        const payment = await (0, yookassa_client_1.createPayment)(Number(order.total), orderId);
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
    async getPaymentStatus(paymentId) {
        const payment = await (0, yookassa_client_1.getPayment)(paymentId);
        return payment.status; // pending | succeeded | canceled
    }
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