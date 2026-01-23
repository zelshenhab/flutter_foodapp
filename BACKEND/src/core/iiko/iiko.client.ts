// src/core/iiko/iiko.client.ts
import axios from "axios";
import {
  IIKO_API_LOGIN,
  IIKO_BASE_URL,
} from "./iiko.constants";

export class IikoClient {
  private token: string | null = null;
  private tokenExpiresAt = 0;

  /** -------------------------------------------
   *  Refresh access token
   * ------------------------------------------- */
  private async refreshToken() {
    const res = await axios.post(
      `${IIKO_BASE_URL}/access_token`,
      { apiLogin: IIKO_API_LOGIN },
      { timeout: 10000 }
    );

    this.token = res.data.token;
    this.tokenExpiresAt = Date.now() + 1000 * 60 * 50;

    console.log("🔐 IIKO token refreshed");
  }

  /** -------------------------------------------
   *  Get valid token
   * ------------------------------------------- */
  private async getToken(): Promise<string> {
    if (!this.token || Date.now() > this.tokenExpiresAt) {
      await this.refreshToken();
    }
    return this.token!;
  }

  /** -------------------------------------------
   *  Authenticated request
   * ------------------------------------------- */
  async request<T>(
    method: "GET" | "POST",
    endpoint: string,
    body?: unknown
  ): Promise<T> {
    const token = await this.getToken();

    const res = await axios({
      method,
      url: `${IIKO_BASE_URL}${endpoint}`,
      data: body,
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      timeout: 15000,
    });

    return res.data as T;
  }
}

export const iikoClient = new IikoClient();
