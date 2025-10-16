import { supabase } from "../../core/config/supabase";
import { PromoDto } from "./promo.types";

const fallbackPromos: PromoDto[] = [
  { id: "p1", title: "Скидка новичкам", description: "10% на первый заказ от 1000 ₽", type: "percent", amount: 10, code: "WELCOME", validTo: null },
  { id: "p2", title: "Комбо выходного", description: "Скидка 300 ₽ при заказе от 1500 ₽", type: "fixed", amount: 300, code: "WEEKEND300", validTo: null },
  { id: "p3", title: "Бесплатный соус", description: "Добавьте соус бесплатно к шаурме", type: "fixed", amount: 50, code: "FREESAUCE", validTo: null },
];

export async function fetchActivePromos(): Promise<PromoDto[]> {
  if (!supabase) return fallbackPromos;
  const { data, error } = await supabase.from("promos").select("id,title,description,type,amount,code,valid_to");
  if (error || !data) return fallbackPromos;
  return data.map((p: any) => ({
    id: p.id,
    title: p.title,
    description: p.description,
    type: p.type,
    amount: Number(p.amount),
    code: p.code,
    validTo: p.valid_to,
  }));
}

export async function findPromoByCode(code: string): Promise<PromoDto | null> {
  if (!supabase) return fallbackPromos.find((p) => p.code.toLowerCase() === code.toLowerCase()) || null;
  const { data, error } = await supabase
    .from("promos")
    .select("id,title,description,type,amount,code,valid_to")
    .ilike("code", code)
    .maybeSingle();
  if (error || !data) return null;
  return {
    id: data.id,
    title: data.title,
    description: data.description,
    type: data.type,
    amount: Number(data.amount),
    code: data.code,
    validTo: data.valid_to,
  };
}

