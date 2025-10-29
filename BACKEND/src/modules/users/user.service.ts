import { supabase } from "../../core/config/supabase";

export async function getMe(userId: number) {
  const { data, error } = await supabase
    .from("User")
    .select("id, phone, name, avatarUrl, createdAt")
    .eq("id", userId)
    .single();

  if (error || !data) throw { status: 404, message: "User not found" };
  return data;
}

export async function updateMe(
  userId: number,
  patch: { name?: string; avatarUrl?: string | null }
) {
  if (Object.keys(patch).length === 0) return getMe(userId);

  const { data, error } = await supabase
    .from("User")
    .update(patch)
    .eq("id", userId)
    .select("id, phone, name, avatarUrl, createdAt")
    .single();

  if (error || !data) throw { status: 500, message: "Profile update failed" };
  return data;
}
