export interface AdminPromoCreate {
  code: string;
  title: string;
  description?: string;
  type: "percent" | "fixed";
  value: number;
  validFrom?: string | null;
  validTo?: string | null;
  minSubtotal?: number | null;
  active: boolean;
}

export interface AdminPromoUpdate {
  code?: string;
  title?: string;
  description?: string | null;
  type?: "percent" | "fixed";
  value?: number;
  validFrom?: string | null;
  validTo?: string | null;
  minSubtotal?: number | null;
  active?: boolean;
}
