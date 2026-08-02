"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listOrders = listOrders;
exports.getOrder = getOrder;
exports.updateStatus = updateStatus;
const supabase_1 = require("../../core/config/supabase");
async function listOrders(filters) {
    const { status, page = 1, limit = 20 } = filters;
    let q = supabase_1.supabase
        .from("Order")
        .select(`
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
      `, { count: "exact" })
        .order("createdAt", { ascending: false });
    if (status) {
        q = q.eq("status", status);
    }
    q = q.range((page - 1) * limit, page * limit - 1);
    const { data, error, count } = await q;
    if (error)
        throw error;
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
async function getOrder(orderId) {
    const { data, error } = await supabase_1.supabase
        .from("Order")
        .select(`
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
      `)
        .eq("id", orderId)
        .single();
    if (error)
        throw error;
    return data;
}
async function updateStatus(orderId, payload) {
    const { data, error } = await supabase_1.supabase
        .from("Order")
        .update({ status: payload.status })
        .eq("id", orderId)
        .select()
        .single();
    if (error)
        throw error;
    return data;
}
//# sourceMappingURL=admin.order.service.js.map