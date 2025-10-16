import { db, UserProfile } from "../../core/config/db";
import { supabase } from "../../core/config/supabase";

export async function getUserProfile(userId: string): Promise<UserProfile | null> {
  if (supabase) {
    const { data, error } = await supabase
      .from("users")
      .select("user_id,name,phone,email,address,notifications,language_code,avatar_path")
      .eq("user_id", userId)
      .maybeSingle();
    if (!error && data) {
      return {
        userId: data.user_id,
        name: data.name,
        phone: data.phone,
        email: data.email ?? undefined,
        address: data.address,
        notifications: data.notifications,
        languageCode: data.language_code,
        avatarPath: data.avatar_path ?? undefined,
      };
    }
  }
  return db.users.get(userId) ?? null;
}

export async function updateUserProfile(userId: string, updates: Partial<UserProfile>): Promise<UserProfile | null> {
  if (supabase) {
    const payload: any = {
      name: updates.name,
      email: updates.email,
      address: updates.address,
      notifications: updates.notifications,
      language_code: updates.languageCode,
      avatar_path: updates.avatarPath,
    };
    Object.keys(payload).forEach((k) => payload[k] === undefined && delete payload[k]);
    const { data, error } = await supabase
      .from("users")
      .update(payload)
      .eq("user_id", userId)
      .select("user_id,name,phone,email,address,notifications,language_code,avatar_path")
      .single();
    if (!error && data) {
      return {
        userId: data.user_id,
        name: data.name,
        phone: data.phone,
        email: data.email ?? undefined,
        address: data.address,
        notifications: data.notifications,
        languageCode: data.language_code,
        avatarPath: data.avatar_path ?? undefined,
      };
    }
  }
  const current = db.users.get(userId);
  if (!current) return null;
  const next: UserProfile = { ...current, ...updates };
  db.users.set(userId, next);
  return next;
}

