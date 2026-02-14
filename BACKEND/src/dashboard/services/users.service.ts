import { supabase } from "../../core/config/supabase";
import { AdminUser } from "../models/users.model";

const USER_TABLE = "User";

// Fetch all users
export async function fetchUsers(limit: number, offset: number) {
  const { data, error } = await supabase
    .from(USER_TABLE)
    .select("id, name, email, avatarUrl, role, blocked, createdAt")
    .order("createdAt", { ascending: false })
    .range(offset, offset + limit - 1);

  if (error) throw error;
  return data;
}

export async function countUsers(): Promise<number> {
  const { count, error } = await supabase
    .from(USER_TABLE)
    .select("*", { count: "exact", head: true });

  if (error) throw error;
  return count ?? 0;
}

// Get one user
export async function fetchUser(id: number): Promise<AdminUser | null> {
  const { data, error } = await supabase
    .from(USER_TABLE)
    .select("*")
    .eq("id", id)
    .maybeSingle();

  if (error) throw error;
  return data ? (data as AdminUser) : null;
}

// Block user
// Block user
export async function blockUser(id: number): Promise<boolean> {
  try {
    console.log('🛑 Attempting to block user:', id);
    
    const { data, error } = await supabase
      .from(USER_TABLE)
      .update({ blocked: true })
      .eq("id", id)
      .select();

    console.log('🔧 Block user response:', { data, error });

    if (error) {
      console.error('❌ Supabase error blocking user:', {
        message: error.message,
        details: error.details,
        hint: error.hint,
        code: error.code
      });
      throw error;
    }
    
    console.log('✅ User blocked successfully');
    return true;
  } catch (error) {
    console.error('❌ BLOCK USER SERVICE ERROR:', error);
    throw error; // Re-throw so error handler can see it
  }
}

// Unblock user
export async function unblockUser(id: number): Promise<boolean> {
  const { error } = await supabase
    .from(USER_TABLE)
    .update({ blocked: false })
    .eq("id", id);

  if (error) throw error;
  return true;
}

// Update role
export async function updateUserRole(
  id: number,
  role: string
): Promise<boolean> {
  const { error } = await supabase
    .from(USER_TABLE)
    .update({ role })
    .eq("id", id);

  if (error) throw error;
  return true;
}
