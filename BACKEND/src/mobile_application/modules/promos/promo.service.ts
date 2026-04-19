import { supabase } from "../../../core/config/supabase";

export async function fetchPromos() {
  const now = new Date().toISOString();

  console.log("Fetching promos at:", now);

  const { data, error } = await supabase
    .from("Promo")
    .select("*")
    .eq("active", true)
    .or(`"validFrom".is.null,"validFrom".lte.${now}`)  // Use quotes for column names
    .or(`"validTo".is.null,"validTo".gte.${now}`)      // validTo is null OR >= now
    .order("id", { ascending: false });

  if (error) {
    console.error("Error fetching promos:", error);
    throw { status: 500, message: "Failed to fetch promos", details: error.message };
  }

  console.log(`Found ${data?.length || 0} active promos`);
  
  // Log each promo for debugging
  data?.forEach(promo => {
    console.log(`Promo: ${promo.code}, validFrom: ${promo.validFrom}, validTo: ${promo.validTo}`);
  });

  return data ?? [];
}

export async function validatePromo(code: string, subtotal: number, userId?: number) {
  const now = new Date().toISOString();
  
  // Get promo with all details
  const { data: promo, error } = await supabase
    .from("Promo")
    .select("*")
    .eq("code", code.toUpperCase())
    .eq("active", true)
    .single();

  if (error || !promo) {
    throw { status: 400, message: "Промокод не найден" };
  }

  // Check date range
  if (promo.validFrom && new Date(promo.validFrom) > new Date(now)) {
    throw { status: 400, message: "Промокод еще не активен" };
  }
  
  if (promo.validTo && new Date(promo.validTo) < new Date(now)) {
    throw { status: 400, message: "Срок действия промокода истек" };
  }

  // Check minimum subtotal
  const minSubtotal = Number(promo.minSubtotal || 0);
  if (minSubtotal > 0 && subtotal < minSubtotal) {
    throw { status: 400, message: `Минимальная сумма заказа для этого промокода: ${minSubtotal} ₽` };
  }

  // Check usage limit
  if (promo.usageLimit && promo.usageLimit > 0) {
    const { count } = await supabase
      .from("PromoUsage")
      .select("*", { count: 'exact', head: true })
      .eq("promoId", promo.id);

    if (count && count >= promo.usageLimit) {
      throw { status: 400, message: "Промокод достиг лимита использований" };
    }
  }

  // Check if user already used this promo
  if (userId) {
    const { data: existingUsage } = await supabase
      .from("PromoUsage")
      .select("*")
      .eq("promoId", promo.id)
      .eq("userId", userId)
      .maybeSingle();

    if (existingUsage) {
      throw { status: 400, message: "Вы уже использовали этот промокод" };
    }
  }

  // Calculate discount
  let discountAmount = 0;
  const type = promo.type;
  const value = Number(promo.value);

  if (type === "percent") {
    discountAmount = (value / 100) * subtotal;
  } else if (type === "fixed") {
    discountAmount = Math.min(value, subtotal);
  }

  discountAmount = Math.round(discountAmount * 100) / 100;

  return {
    promo,
    discountAmount,
    isValid: true
  };
}

export async function recordPromoUsage(promoId: number, userId: number, orderId: number, discountAmount: number) {
  const { error } = await supabase
    .from("PromoUsage")
    .insert({
      promoId,
      userId,
      orderId,
      discountAmount,
      usedAt: new Date().toISOString()
    });

  if (error) {
    console.error("Failed to record promo usage:", error);
  }

  // Increment used count
  await supabase
    .from("Promo")
    .update({ usedCount: supabase.rpc('increment', { row_id: promoId }) })
    .eq("id", promoId);
}