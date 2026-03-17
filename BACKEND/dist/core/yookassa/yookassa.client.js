"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.createPayment = createPayment;
exports.getPayment = getPayment;
const axios_1 = __importDefault(require("axios"));
const SHOP_ID = process.env.YOOKASSA_SHOP_ID;
const SECRET = process.env.YOOKASSA_SECRET_KEY;
const auth = Buffer.from(`${SHOP_ID}:${SECRET}`).toString("base64");
const api = axios_1.default.create({
    baseURL: "https://api.yookassa.ru/v3",
    headers: {
        Authorization: `Basic ${auth}`,
        "Content-Type": "application/json",
    },
});
/// ✅ CREATE PAYMENT
async function createPayment(amount, orderId) {
    const res = await api.post("/payments", {
        amount: {
            value: amount.toFixed(2),
            currency: "RUB",
        },
        capture: true,
        confirmation: {
            type: "redirect",
            return_url: process.env.YOOKASSA_RETURN_URL, // adamandeve://payment-success
        },
        description: `Order #${orderId}`,
        metadata: {
            orderId,
        },
    }, {
        headers: {
            "Idempotence-Key": `${Date.now()}-${orderId}`,
        },
    });
    return res.data;
}
/// ✅ GET PAYMENT STATUS
async function getPayment(paymentId) {
    const res = await api.get(`/payments/${paymentId}`);
    return res.data;
}
//# sourceMappingURL=yookassa.client.js.map