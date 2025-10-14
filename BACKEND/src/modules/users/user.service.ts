import { db, UserProfile } from "../../core/config/db";

export function getUserProfile(userId: string): UserProfile | null {
  return db.users.get(userId) ?? null;
}

export function updateUserProfile(userId: string, updates: Partial<UserProfile>): UserProfile | null {
  const current = db.users.get(userId);
  if (!current) return null;
  const next: UserProfile = { ...current, ...updates };
  db.users.set(userId, next);
  return next;
}

