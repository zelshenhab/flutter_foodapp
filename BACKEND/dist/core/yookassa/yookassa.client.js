"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.createPayment = createPayment;
const axios_1 = __importDefault(require("axios"));
const SHOP_ID = process.env.YOOKASSA_SHOP_ID;
const SECRET = process.env.YOOKASSA_SECRET_KEY;
async function createPayment(amount, orderId) {
    const auth = Buffer.from(`${SHOP_ID}:${SECRET}`).toString("base64");
    const res = await axios_1.default.post("https://api.yookassa.ru/v3/payments", {
        amount: {
            value: amount.toFixed(2),
            currency: "RUB",
        },
        capture: true,
        confirmation: {
            type: "redirect",
            return_url: process.env.YOOKASSA_RETURN_URL,
        },
        description: `Order #${orderId}`,
        metadata: {
            orderId,
        },
    }, {
        headers: {
            Authorization: `Basic ${auth}`,
            "Content-Type": "application/json",
            "Idempotence-Key": `${Date.now()}-${orderId}`,
        },
    });
    return res.data;
}
//# sourceMappingURL=yookassa.client.js.map