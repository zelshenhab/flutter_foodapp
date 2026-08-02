import { supabase } from "../../core/config/supabase";
import { AdminOrderFilters, AdminOrderUpdateStatus } from "../models/admin.order.types";

export async function listOrders(filters: AdminOrderFilters) {
  const { status, page = 1, limit = 20 } = filters;

  let q = supabase
    .from("Order")
    .select(
      `
        *,
        User(*),
        OrderItem!OrderItem_orderId_fkey(
          id,
          orderId,
          menuItemId,
          titleSnap,
          optionsSnap,
          unitPrice,
          quantity,
          lineTotal
        )
      `,
      { count: "exact" }
    )
    .order("createdAt", { ascending: false });

  if (status) {
    q = q.eq("status", status);
  }

  q = q.range((page - 1) * limit, page * limit - 1);

  const { data, error, count } = await q;

  if (error) throw error;

  return {
    data,
    pagination: {
      total: count ?? 0,
      page,
      limit,
      totalPages: Math.ceil((count ?? 0) / limit),
    },
  };
}


export async function getOrder(orderId: number) {
  const { data, error } = await supabase
    .from("Order")
    .select(
      `
        *,
        User(*),
        OrderItem!OrderItem_orderId_fkey(
          id,
          orderId,
          menuItemId,
          titleSnap,
          optionsSnap,
          unitPrice,
          quantity,
          lineTotal
        )
      `
    )
    .eq("id", orderId)
    .single();

  if (error) throw error;

  return data;
}

export async function updateStatus(orderId: number, payload: AdminOrderUpdateStatus) {
  const { data, error } = await supabase
    .from("Order")
    .update({ status: payload.status })
    .eq("id", orderId)
    .select()
    .single();

  if (error) throw error;

  return data;
}
