import { db, ensureUserByPhone } from "../../core/config/db";
import { signAuthToken } from "../../core/utils/jwt";
import { supabase } from "../../core/config/supabase";

async function ensureSupabaseUserByPhone(phone: string) {
  if (!supabase) return ensureUserByPhone(phone);
  // Try to find by phone
  const { data: usersByPhone, error: findErr } = await supabase
    .from("users")
    .select("user_id,name,phone,email,address,notifications,language_code,avatar_path")
    .eq("phone", phone)
    .maybeSingle();
  if (!findErr && usersByPhone) {
    return {
      userId: usersByPhone.user_id,
      name: usersByPhone.name,
      phone: usersByPhone.phone,
      email: usersByPhone.email ?? undefined,
      address: usersByPhone.address,
      notifications: usersByPhone.notifications,
      languageCode: usersByPhone.language_code,
      avatarPath: usersByPhone.avatar_path ?? undefined,
    };
  }
  // Create one
  const digits = phone.replace(/\D/g, "");
  const userId = `u_${digits || Math.random().toString(36).slice(2)}`;
  const { data: created, error: insertErr } = await supabase
    .from("users")
    .insert({
      user_id: userId,
      name: "User",
      phone,
      address: "ул. Пушкина 15",
      notifications: true,
      language_code: "ru",
    })
    .select("user_id,name,phone,email,address,notifications,language_code,avatar_path")
    .single();
  if (insertErr || !created) {
    // fallback local
    return ensureUserByPhone(phone);
  }
  return {
    userId: created.user_id,
    name: created.name,
    phone: created.phone,
    email: created.email ?? undefined,
    address: created.address,
    notifications: created.notifications,
    languageCode: created.language_code,
    avatarPath: created.avatar_path ?? undefined,
  };
}

export function sendOtp(phone: string): boolean {
  const normalized = phone.trim();
  const code = process.env.DEMO_OTP_CODE || "1234";
  db.otps.set(normalized, code);
  // In real world, integrate SMS provider here
  ensureUserByPhone(normalized);
  return true;
}

export async function verifyOtp(phone: string, code: string) {
  const normalized = phone.trim();
  const expected = db.otps.get(normalized);
  if (!expected || expected !== code) {
    return null;
  }
  const profile = await ensureSupabaseUserByPhone(normalized);
  const token = signAuthToken({ userId: profile.userId, phone: normalized });
  // one-time use
  db.otps.delete(normalized);
  return { token, user: profile };
}

