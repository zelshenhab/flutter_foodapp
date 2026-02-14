import nodemailer from "nodemailer";

const smtpUser = process.env.SMTP_USER;
const smtpPass = process.env.SMTP_PASS;
const smtpFrom = process.env.SMTP_FROM;

if (!smtpUser || !smtpPass) {
  console.warn("⚠️ SMTP credentials missing.");
}

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: smtpUser,
    pass: smtpPass,
  },
});

export async function sendOtpEmailSMTP(params: {
  to: string;
  code: string;
  ttlMinutes: number;
}) {
  if (!smtpUser || !smtpPass || !smtpFrom) {
    throw new Error("SMTP credentials not configured");
  }

  const { to, code, ttlMinutes } = params;

  await transporter.sendMail({
    from: smtpFrom,
    to,
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

  console.log("✅ OTP email sent via SMTP");
}
