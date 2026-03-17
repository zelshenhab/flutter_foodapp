"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PaymentController = void 0;
const payment_service_1 = require("./payment.service");
class PaymentController {
    static async createPayment(req, res, next) {
        try {
            console.log("====== CREATE PAYMENT ======");
            console.log("HEADERS:", req.headers);
            console.log("BODY:", req.body);
            console.log("USER:", req.user);
            const userId = req.user?.id;
            if (!userId) {
                console.log("❌ USER NOT AUTHENTICATED");
                return res.status(401).json({ error: "Unauthorized" });
            }
            const { orderId } = req.body;
            if (!orderId) {
                console.log("❌ orderId missing");
                return res.status(400).json({ error: "orderId required" });
            }
            console.log("Creating payment for order:", orderId);
            console.log("User:", userId);
            const url = await payment_service_1.paymentService.createPayment(orderId, userId);
            console.log("✅ Payment created:", url);
            res.json({
                confirmationUrl: url,
            });
        }
        catch (e) {
            console.error("❌ PAYMENT ERROR:", e);
            next(e);
        }
    }
    static async webhook(req, res) {
        console.log("====== YOOKASSA WEBHOOK ======");
        console.log("EVENT:", req.body);
        const event = req.body;
        if (event.object?.status === "succeeded") {
            const paymentId = event.object.id;
            console.log("Payment succeeded:", paymentId);
            await payment_service_1.paymentService.markOrderPaid(paymentId);
        }
        res.json({ ok: true });
    }
}
exports.PaymentController = PaymentController;
//# sourceMappingURL=payment.controller.js.map