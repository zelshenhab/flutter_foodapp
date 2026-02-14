"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PaymentController = void 0;
const payment_service_1 = require("./payment.service");
class PaymentController {
    /**
     * Called AFTER external payment success
     */
    static async confirmPayment(req, res, next) {
        try {
            const { orderId } = req.body;
            if (!orderId) {
                return res.status(400).json({ error: "orderId required" });
            }
            await payment_service_1.paymentService.registerPaymentInIiko(orderId);
            res.json({ success: true });
        }
        catch (e) {
            next(e);
        }
    }
    static async webhook(req, res) {
        // future SBP provider webhook
        res.json({ ok: true });
    }
}
exports.PaymentController = PaymentController;
//# sourceMappingURL=payment.controller.js.map