import { supabase } from "../../core/config/supabase";
import { AdminPromoCreate, AdminPromoUpdate } from "../models/admin.promo.types";

export async function listPromos() {
  const { data, error } = await supabase
    .from("Promo")
    .select("*")
    .order("id", { ascending: true });

  if (error) throw error;
  return data;
}

export async function createPromo(payload: AdminPromoCreate) {
  const {
    code,
    title,
    description,
    type,
    value,
    validFrom,
    validTo,
    minSubtotal,
    active,
  } = payload;

  const { data, error } = await supabase
    .from("Promo")
    .insert([
      {
        code,
        title,
        description: description ?? null,
        type,
        value,
        validFrom: validFrom ?? null,
        validTo: validTo ?? null,
        minSubtotal: minSubtotal ?? null,
        active,
      },
    ])
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function updatePromo(id: number, payload: AdminPromoUpdate) {
  const patch: AdminPromoUpdate = {};

  if (typeof payload.code === "string") patch.code = payload.code;
  if (typeof payload.title === "string") patch.title = payload.title;
  if (payload.description !== undefined) patch.description = payload.description;
  if (payload.type) patch.type = payload.type;
  if (typeof payload.value === "number") patch.value = payload.value;
  if (payload.validFrom !== undefined) patch.validFrom = payload.validFrom;
  if (payload.validTo !== undefined) patch.validTo = payload.validTo;
  if (payload.minSubtotal !== undefined) patch.minSubtotal = payload.minSubtotal;
  if (typeof payload.active === "boolean") patch.active = payload.active;

  const { data, error } = await supabase
    .from("Promo")
    .update(patch)
    .eq("id", id)
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function deletePromo(id: number) {
  const { error } = await supabase.from("Promo").delete().eq("id", id);
  if (error) throw error;
}
