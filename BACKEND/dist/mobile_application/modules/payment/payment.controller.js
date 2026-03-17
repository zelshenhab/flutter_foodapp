"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PaymentController = void 0;
const payment_service_1 = require("./payment.service");
class PaymentController {
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
            const result = await payment_service_1.paymentService.createPayment(Number(orderId), userId);
            return res.json(result);
        }
        catch (e) {
            console.error("❌ PAYMENT ERROR:", e);
            next(e);
        }
    }
    static async getStatus(req, res) {
        try {
            const { paymentId } = req.params;
            if (!paymentId) {
                return res.status(400).json({ error: "paymentId required" });
            }
            const status = await payment_service_1.paymentService.syncOrderWithPayment(paymentId);
            return res.json({ status });
        }
        catch (e) {
            console.error("❌ STATUS ERROR:", e);
            return res.status(500).json({ error: "Failed to get payment status" });
        }
    }
    static async webhook(req, res) {
        try {
            console.log("====== YOOKASSA WEBHOOK ======");
            console.log("EVENT:", req.body);
            const event = req.body;
            if (event.object?.id) {
                const paymentId = event.object.id;
                await payment_service_1.paymentService.syncOrderWithPayment(paymentId);
            }
            return res.json({ ok: true });
        }
        catch (e) {
            console.error("❌ WEBHOOK ERROR:", e);
            return res.status(500).json({ ok: false });
        }
    }
}
exports.PaymentController = PaymentController;
//# sourceMappingURL=payment.controller.js.map