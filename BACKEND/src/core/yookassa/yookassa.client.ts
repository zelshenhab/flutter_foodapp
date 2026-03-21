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

/// 🔥 TYPES
type ReceiptItem = {
  description: string;
  quantity: string;
  amount: {
    value: string;
    currency: string;
  };
  vat_code: number;
};

type CreatePaymentParams = {
  amount: number;
  orderId: number;
  email: string;
  items: ReceiptItem[];
};

/// ================= CREATE PAYMENT =================
export async function createPayment({
  amount,
  orderId,
  email,
  items,
}: CreatePaymentParams) {
  try {
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

        /// 🔥 REQUIRED FOR LIVE MODE
        receipt: {
          customer: {
            email,
          },
          items,
        },
      },
      {
        headers: {
          "Idempotence-Key": `${Date.now()}-${orderId}`,
        },
      }
    );

    return res.data;
  } catch (error: any) {
    console.error("❌ YooKassa ERROR:", error?.response?.data || error.message);
    throw error;
  }
}

/// ================= GET PAYMENT =================
export async function getPayment(paymentId: string) {
  const res = await api.get(`/payments/${paymentId}`);
  return res.data;
}