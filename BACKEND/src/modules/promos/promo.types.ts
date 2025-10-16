export type PromoType = "percent" | "fixed";

export interface PromoDto {
  id: string;
  title: string;
  description: string;
  type: PromoType;
  amount: number;
  code: string;
  validTo?: string | null; // ISO date or null
}

export interface ValidatePromoRequest {
  code: string;
}

