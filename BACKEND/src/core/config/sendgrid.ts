import sgMail from "@sendgrid/mail";

const apiKey = process.env.SENDGRID_API_KEY;
const fromEmail = process.env.SENDGRID_FROM_EMAIL;

if (!apiKey) {
  console.warn("⚠️ SENDGRID_API_KEY is missing.");
} else {
  sgMail.setApiKey(apiKey);
}

export async function sendOtpEmail(params: {
  to: string;
  code: string;
  ttlMinutes: number;
}) {
  if (!apiKey) throw new Error("SENDGRID_API_KEY is not set");
  if (!fromEmail) throw new Error("SENDGRID_FROM_EMAIL is not set");

  const { to, code, ttlMinutes } = params;

  await sgMail.send({
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
