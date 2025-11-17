export interface AnalyticsRangeQuery {
  from?: string;  // ISO date
  to?: string;    // ISO date
}

export interface DailyRevenue {
  date: string;
  total: number;
}

export interface OrdersByStatus {
  pending: number;
  preparing: number;
  delivering: number;
  completed: number;
  cancelled: number;
}

export interface BestSellingItem {
  menuItemId: number;
  title: string;
  qty: number;
  total: number;
}

export interface DashboardStats {
  totalRevenue: number;
  totalOrders: number;
  activeUsers: number;
  avgOrderValue: number;
}
