import { supabase } from "../../core/config/supabase";
import {
  AnalyticsRangeQuery,
  DailyRevenue,
  OrdersByStatus,
  BestSellingItem,
  DashboardStats
} from "../models/admin.analytics.types";

/* ---------- DATE RANGE HELPERS ---------- */

function dateRange(range: AnalyticsRangeQuery) {
  const from = range.from ?? "1970-01-01";
  const to = range.to ?? new Date().toISOString();
  return { from, to };
}

/* ---------- 1. DAILY REVENUE ---------- */

export async function dailyRevenue(range: AnalyticsRangeQuery): Promise<DailyRevenue[]> {
  const { from, to } = dateRange(range);

  const { data, error } = await supabase
    .from("Order")
    .select("createdAt, total")
    .gte("createdAt", from)
    .lte("createdAt", to)
    .order("createdAt", { ascending: true });

  if (error) throw error;

  // group by day
  const map = new Map<string, number>();
  data?.forEach((o) => {
    const day = o.createdAt.split("T")[0];
    map.set(day, (map.get(day) ?? 0) + o.total);
  });

  return Array.from(map, ([date, total]) => ({ date, total }));
}

/* ---------- 2. ORDERS BY STATUS ---------- */

export async function ordersByStatus(range: AnalyticsRangeQuery): Promise<OrdersByStatus> {
  const { from, to } = dateRange(range);

  const { data, error } = await supabase
    .from("Order")
    .select("status")
    .gte("createdAt", from)
    .lte("createdAt", to);

  if (error) throw error;

  const result: OrdersByStatus = {
    pending: 0,
    preparing: 0,
    delivering: 0,
    completed: 0,
    cancelled: 0,
  };

  data?.forEach((o) => {
    const status = o.status as keyof OrdersByStatus;
    if (status in result) {
      result[status]++;
    }
  });

  return result;
}

/* ---------- 3. BEST SELLING ITEMS ---------- */

export async function bestSellingItems(range: AnalyticsRangeQuery): Promise<BestSellingItem[]> {
  const { from, to } = dateRange(range);

  const { data, error } = await supabase
    .from("order_items")
    .select("menuItemId, titleSnap, quantity, lineTotal, orders!inner(createdAt)")
    .gte("orders.createdAt", from)
    .lte("orders.createdAt", to);

  if (error) throw error;

  const map = new Map<number, { title: string; qty: number; total: number }>();

  data?.forEach((item) => {
    const entry = map.get(item.menuItemId) || {
      title: item.titleSnap,
      qty: 0,
      total: 0,
    };

    entry.qty += item.quantity;
    entry.total += item.lineTotal;

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

export async function dashboardStats(range: AnalyticsRangeQuery): Promise<DashboardStats> {
  const { from, to } = dateRange(range);

  const orders = await supabase
    .from("Order")
    .select("total, userId")
    .gte("createdAt", from)
    .lte("createdAt", to);

  if (orders.error) throw orders.error;

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
