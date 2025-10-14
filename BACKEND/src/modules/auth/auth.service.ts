import { db, ensureUserByPhone } from "../../core/config/db";
import { signAuthToken } from "../../core/utils/jwt";

export function sendOtp(phone: string): boolean {
  const normalized = phone.trim();
  const code = process.env.DEMO_OTP_CODE || "1234";
  db.otps.set(normalized, code);
  // In real world, integrate SMS provider here
  ensureUserByPhone(normalized);
  return true;
}

export function verifyOtp(phone: string, code: string) {
  const normalized = phone.trim();
  const expected = db.otps.get(normalized);
  if (!expected || expected !== code) {
    return null;
  }
  const profile = ensureUserByPhone(normalized);
  const token = signAuthToken({ userId: profile.userId, phone: profile.phone });
  // one-time use
  db.otps.delete(normalized);
  return { token, user: profile };
}

