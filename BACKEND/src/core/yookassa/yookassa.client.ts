import axios from "axios";

const SHOP_ID = process.env.YOOKASSA_SHOP_ID!;
const SECRET = process.env.YOOKASSA_SECRET_KEY!;

export async function createPayment(amount: number, orderId: number) {
  const auth = Buffer.from(`${SHOP_ID}:${SECRET}`).toString("base64");

  const res = await axios.post(
    "https://api.yookassa.ru/v3/payments",
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
        Authorization: `Basic ${auth}`,
        "Content-Type": "application/json",
        "Idempotence-Key": `${Date.now()}-${orderId}`,
      },
    }
  );

  return res.data;
}