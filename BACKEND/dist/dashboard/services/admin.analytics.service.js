"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.dailyRevenue = dailyRevenue;
exports.ordersByStatus = ordersByStatus;
exports.bestSellingItems = bestSellingItems;
exports.dashboardStats = dashboardStats;
const supabase_1 = require("../../core/config/supabase");
/* ---------- DATE RANGE HELPERS ---------- */
function dateRange(range) {
    const from = range.from ?? "1970-01-01";
    const to = range.to ?? new Date().toISOString();
    return { from, to };
}
/* ---------- 1. DAILY REVENUE ---------- */
async function dailyRevenue(range) {
    const { from, to } = dateRange(range);
    const { data, error } = await supabase_1.supabase
        .from("Order")
        .select("createdAt, total")
        .gte("createdAt", from)
        .lte("createdAt", to)
        .order("createdAt", { ascending: true });
    if (error)
        throw error;
    // group by day
    const map = new Map();
    data?.forEach((o) => {
        const day = o.createdAt.split("T")[0];
        map.set(day, (map.get(day) ?? 0) + o.total);
    });
    return Array.from(map, ([date, total]) => ({ date, total }));
}
/* ---------- 2. ORDERS BY STATUS ---------- */
async function ordersByStatus(range) {
    const { from, to } = dateRange(range);
    const { data, error } = await supabase_1.supabase
        .from("Order")
        .select("status")
        .gte("createdAt", from)
        .lte("createdAt", to);
    if (error)
        throw error;
    const result = {
        pending: 0,
        preparing: 0,
        delivering: 0,
        completed: 0,
        cancelled: 0,
    };
    data?.forEach((o) => {
        const status = o.status;
        if (status in result) {
            result[status]++;
        }
    });
    return result;
}
/* ---------- 3. BEST SELLING ITEMS ---------- */
async function bestSellingItems(range) {
    const { from, to } = dateRange(range);
    const { data, error } = await supabase_1.supabase
        .from("OrderItem")
        .select(`
      menuItemId,
      titleSnap,
      quantity,
      lineTotal,
      order:Order!OrderItem_orderId_fkey(createdAt)
    `)
        .gte("order.createdAt", from)
        .lte("order.createdAt", to);
    if (error)
        throw error;
    const map = new Map();
    data?.forEach((item) => {
        const entry = map.get(item.menuItemId) || {
            title: item.titleSnap,
            qty: 0,
            total: 0,
        };
        entry.qty += Number(item.quantity);
        entry.total += Number(item.lineTotal);
        map.set(item.menuItemId, entry);
    });
    return Array.from(map, ([menuItemId, v]) => ({
        menuItemId,
        title: v.title,
        qty: v.qty,
        total: v.total,
    })).sort((a, b) => b.qty - a.qty);
}
/* ---------- 4. DASHBOARD SUMMARY ---------- */
async function dashboardStats(range) {
    const { from, to } = dateRange(range);
    const orders = await supabase_1.supabase
        .from("Order")
        .select("total, userId")
        .gte("createdAt", from)
        .lte("createdAt", to);
    if (orders.error)
        throw orders.error;
    const totalRevenue = orders.data.reduce((s, o) => s + o.total, 0);
    const totalOrders = orders.data.length;
    const avgOrderValue = totalOrders === 0 ? 0 : totalRevenue / totalOrders;
    const uniqueUsers = new Set(orders.data.map((o) => o.userId)).size;
    return {
        totalRevenue,
        totalOrders,
        activeUsers: uniqueUsers,
        avgOrderValue,
    };
}
//# sourceMappingURL=admin.analytics.service.js.map