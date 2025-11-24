// src/core/iiko/iiko.payment.service.ts
import { iikoClient } from "./iiko.client";
import {
  IikoCreatePaymentRequest,
  IikoCreatePaymentResponse,
  IikoPaymentStatusResponse,
} from "./iiko.types";

const ORGANIZATION_ID = "org-123456789"; // replace later

class IikoPaymentService {
  async createPayment(orderId: number, amount: number): Promise<IikoCreatePaymentResponse> {
    const body: IikoCreatePaymentRequest = {
      organizationId: ORGANIZATION_ID,
      amount,
      currency: "RUB",
      order: { id: String(orderId) },
      paymentMethod: "Card",
    };

    const data = await iikoClient.request("POST", "/createPayment", body);
    return data as IikoCreatePaymentResponse;
  }

  async checkPaymentStatus(paymentId: string): Promise<IikoPaymentStatusResponse> {
    const data = await iikoClient.request("POST", "/getPaymentStatus", {
      paymentId,
      organizationId: ORGANIZATION_ID,
    });

    return data as IikoPaymentStatusResponse;
  }
}

export const iikoPaymentService = new IikoPaymentService();
