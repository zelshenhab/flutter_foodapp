"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PaymentController = void 0;
const payment_service_1 = require("./payment.service");
class PaymentController {
    /// 🔹 CREATE PAYMENT
    static async createPayment(req, res, next) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: "Unauthorized" });
            }
            const { orderId } = req.body;
            if (!orderId) {
                return res.status(400).json({ error: "orderId required" });
            }
            const result = await payment_service_1.paymentService.createPayment(orderId, userId);
            res.json(result); // 🔥 returns paymentId + confirmationUrl
        }
        catch (e) {
            console.error("❌ PAYMENT ERROR:", e);
            next(e);
        }
    }
    /// 🔥 GET PAYMENT STATUS
    static async getStatus(req, res) {
        try {
            const { paymentId } = req.params;
            if (!paymentId) {
                return res.status(400).json({ error: "paymentId required" });
            }
            const status = await payment_service_1.paymentService.getPaymentStatus(paymentId);
            res.json({ status });
        }
        catch (e) {
            console.error("❌ STATUS ERROR:", e);
            res.status(500).json({ error: "Failed to get payment status" });
        }
    }
    /// 🔥 YOOKASSA WEBHOOK
    static async webhook(req, res) {
        try {
            console.log("====== YOOKASSA WEBHOOK ======");
            console.log("EVENT:", req.body);
            const event = req.body;
            if (event.object?.status === "succeeded") {
                const paymentId = event.object.id;
                console.log("✅ Payment succeeded:", paymentId);
                await payment_service_1.paymentService.markOrderPaid(paymentId);
            }
            res.json({ ok: true });
        }
        catch (e) {
            console.error("❌ WEBHOOK ERROR:", e);
            res.status(500).json({ ok: false });
        }
    }
}
exports.PaymentController = PaymentController;
//# sourceMappingURL=payment.controller.js.map