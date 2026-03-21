import axios from "axios";

const SHOP_ID = process.env.YOOKASSA_SHOP_ID!;
const SECRET = process.env.YOOKASSA_SECRET_KEY!;

const auth = Buffer.from(`${SHOP_ID}:${SECRET}`).toString("base64");

const api = axios.create({
  baseURL: "https://api.yookassa.ru/v3",
  headers: {
    Authorization: `Basic ${auth}`,
    "Content-Type": "application/json",
  },
});

export async function createPayment(amount: number, orderId: number) {
  const res = await api.post(
    "/payments",
    {
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
    },
    {
      headers: {
        "Idempotence-Key": `${Date.now()}-${orderId}`,
      },
    }
  );

  return res.data;
}

export async function getPayment(paymentId: string) {
  const res = await api.get(`/payments/${paymentId}`);
  return res.data;
}