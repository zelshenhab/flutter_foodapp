// src/core/iiko/iiko.types.ts

/** ------------------------------------------------------------------
 *  Token response from iikoCloud
 * ------------------------------------------------------------------ */
export interface IikoTokenResponse {
  token: string;
}

/** ------------------------------------------------------------------
 *  Create Payment Request
 * ------------------------------------------------------------------ */
export interface IikoCreatePaymentRequest {
  organizationId: string;
  amount: number;
  currency: "RUB";
  order: {
    id: string;
  };
  paymentMethod: "Card" | string;
}

/** ------------------------------------------------------------------
 *  Create Payment Response
 * ------------------------------------------------------------------ */
export interface IikoCreatePaymentResponse {
  paymentId: string;
  paymentUrl: string;
}

/** ------------------------------------------------------------------
 *  Payment Status Response
 * ------------------------------------------------------------------ */
export interface IikoPaymentStatusResponse {
  paymentId: string;
  status: "New" | "InProgress" | "Paid" | "Cancelled" | "Error";
  errorDescription?: string;
}
