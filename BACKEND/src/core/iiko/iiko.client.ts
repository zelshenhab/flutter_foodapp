// src/core/iiko/iiko.client.ts
import axios from "axios";

export class IikoClient {
  private apiLogin = "demo-login-123456789";   // replace later
  private token: string | null = null;
  private tokenExpiresAt: number = 0;

  private baseUrl = "https://api-ru.iiko.services/api/1";

  /** -------------------------------------------
   *  Get new token from iikoCloud
   * ------------------------------------------- */
  private async refreshToken() {
    const url = `${this.baseUrl}/access_token`;

    const res = await axios.post(url, {
      apiLogin: this.apiLogin,
    });

    this.token = res.data.token;
    this.tokenExpiresAt = Date.now() + 1000 * 60 * 50; // token valid for 60 min

    console.log("🔐 New IIKO token acquired");
  }

  /** -------------------------------------------
   *  Ensure token is valid
   * ------------------------------------------- */
  private async getToken() {
    if (!this.token || Date.now() > this.tokenExpiresAt) {
      await this.refreshToken();
    }
    return this.token!;
  }

  /** -------------------------------------------
   *  Make authenticated request to iiko
   * ------------------------------------------- */
  async request(method: "GET" | "POST", endpoint: string, body?: any) {
    const token = await this.getToken();

    const url = `${this.baseUrl}${endpoint}`;

    const res = await axios({
      method,
      url,
      data: body,
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
    });

    return res.data;
  }
}

// export singleton
export const iikoClient = new IikoClient();
