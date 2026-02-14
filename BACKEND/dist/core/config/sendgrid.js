"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendOtpEmail = sendOtpEmail;
const mail_1 = __importDefault(require("@sendgrid/mail"));
const apiKey = process.env.SENDGRID_API_KEY;
const fromEmail = process.env.SENDGRID_FROM_EMAIL;
if (!apiKey) {
    console.warn("⚠️ SENDGRID_API_KEY is missing.");
}
else {
    mail_1.default.setApiKey(apiKey);
}
async function sendOtpEmail(params) {
    if (!apiKey)
        throw new Error("SENDGRID_API_KEY is not set");
    if (!fromEmail)
        throw new Error("SENDGRID_FROM_EMAIL is not set");
    const { to, code, ttlMinutes } = params;
    await mail_1.default.send({
        to,
        from: fromEmail,
        subject: "Your verification code",
        text: `Your verification code is ${code}. It expires in ${ttlMinutes} minutes.`,
        html: `
      <div style="font-family: Arial, sans-serif;">
        <h2>Your verification code</h2>
        <p>Use this code to sign in:</p>
        <div style="font-size: 28px; font-weight: bold; letter-spacing: 4px;">
          ${code}
        </div>
        <p>This code expires in ${ttlMinutes} minutes.</p>
      </div>
    `,
    });
}
//# sourceMappingURL=sendgrid.js.map