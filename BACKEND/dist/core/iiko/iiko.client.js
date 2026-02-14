"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.iikoClient = exports.IikoClient = void 0;
// src/core/iiko/iiko.client.ts
const axios_1 = __importDefault(require("axios"));
const iiko_constants_1 = require("./iiko.constants");
class IikoClient {
    constructor() {
        this.token = null;
        this.tokenExpiresAt = 0;
    }
    /** -------------------------------------------
     *  Refresh access token
     * ------------------------------------------- */
    async refreshToken() {
        const res = await axios_1.default.post(`${iiko_constants_1.IIKO_BASE_URL}/access_token`, { apiLogin: iiko_constants_1.IIKO_API_LOGIN }, { timeout: 10000 });
        this.token = res.data.token;
        this.tokenExpiresAt = Date.now() + 1000 * 60 * 50;
        console.log("🔐 IIKO token refreshed");
    }
    /** -------------------------------------------
     *  Get valid token
     * ------------------------------------------- */
    async getToken() {
        if (!this.token || Date.now() > this.tokenExpiresAt) {
            await this.refreshToken();
        }
        return this.token;
    }
    /** -------------------------------------------
     *  Authenticated request
     * ------------------------------------------- */
    async request(method, endpoint, body) {
        const token = await this.getToken();
        const res = await (0, axios_1.default)({
            method,
            url: `${iiko_constants_1.IIKO_BASE_URL}${endpoint}`,
            data: body,
            headers: {
                Authorization: `Bearer ${token}`,
                "Content-Type": "application/json",
            },
            timeout: 15000,
        });
        return res.data;
    }
}
exports.IikoClient = IikoClient;
exports.iikoClient = new IikoClient();
//# sourceMappingURL=iiko.client.js.map