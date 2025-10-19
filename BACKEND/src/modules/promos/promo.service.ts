import { supabase } from "../../core/config/supabase";

export async function fetchPromos() {
  const now = new Date().toISOString();

  const { data, error } = await supabase
    .from("Promo") // 👈 use your actual table name in Supabase
    .select("*")
    .eq("active", true)
    .lte("validFrom", now)
    .gte("validTo", now)
    .order("id", { ascending: false });

  if (error) {
    throw { status: 500, message: "Failed to fetch promos", details: error.message };
  }

  return data ?? [];
}
