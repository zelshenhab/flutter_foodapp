export interface AdminOrderFilters {
  status?: string;
  page?: number;
  limit?: number;
}

export interface AdminOrderUpdateStatus {
  status: "pending" | "preparing" | "ready" | "completed" | "cancelled";
}
