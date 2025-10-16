import { createClient, type SupabaseClient } from "@supabase/supabase-js";

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;

const key = SUPABASE_SERVICE_ROLE_KEY || SUPABASE_ANON_KEY || "";

export const supabase: SupabaseClient | null = SUPABASE_URL && key
  ? createClient(SUPABASE_URL, key)
  : null;

export const hasServiceRole = Boolean(SUPABASE_SERVICE_ROLE_KEY);
