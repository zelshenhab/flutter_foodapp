import { supabase } from "../../../core/config/supabase";
import { validatePromo } from "../promos/promo.service";
import { calculatePointsRedemption } from "../loyalty/loyalty.service"; // 👈 ADD THIS LINE

// ✅ UPDATE THE Pricing TYPE to include loyalty points
type Pricing = {
  items: Array<{
    id: number;
    title: string;
    quantity: number;
    unitPrice: number;
    lineTotal: number;
    optionIds: number[];
    menuItemId: number;
    image?: string | null;
    categoryId?: string | null;
  }>;
  subtotal: number;
  discount: number;        // Promo discount
  pointsDiscount: number;  // 👈 ADD THIS - Loyalty points discount
  deliveryFee: number;
  total: number;
  promoCode?: string | null;
  promoError?: string | null;
  appliedPoints?: number;   // 👈 ADD THIS
  availablePoints?: number; // 👈 ADD THIS
};

function round2(n: number) {
  return Math.round(n * 100) / 100;
}

function sameNumberSets(a: number[], b: number[]) {
  if (a.length !== b.length) return false;
  const as = [...a].sort((x, y) => x - y);
  const bs = [...b].sort((x, y) => x - y);
  for (let i = 0; i < as.length; i++) if (as[i] !== bs[i]) return false;
  return true;
}

async function getOrCreateCart(userId: number) {
  const { data: existing, error: fetchError } = await supabase
    .from("Cart")
    .select("*")
    .eq("userId", userId)
    .single();

  if (existing && !fetchError) {
    return existing;
  }

  const { data: newCart, error: createError } = await supabase
    .from("Cart")
    .insert({ userId })
    .select()
    .single();

  if (createError) {
    throw { status: 500, message: "Failed to create cart" };
  }

  return newCart;
}

// ✅ UPDATE getCart function to include loyalty points
export async function getCart(userId: number, appliedPoints?: number): Promise<Pricing> {
  const cart = await getOrCreateCart(userId);

  const { data: items, error } = await supabase
    .from("CartItem")
    .select(
      `
      *,
      MenuItem!inner(id, title, imageUrl, categoryId)
    `
    )
    .eq("cartId", cart.id)
    .order("id", { ascending: true });

  if (error) {
    throw { status: 500, message: "Failed to fetch cart items" };
  }

  const mapped =
    items?.map((ci: any) => {
      const unitPrice = Number(ci.unitPriceSnapshot ?? ci.unitPrice ?? 0);
      const lineTotal = Number(ci.lineTotal ?? unitPrice * Number(ci.quantity || 1));

      return {
        id: ci.menuItemId,
        menuItemId: ci.menuItemId,
        title: ci.MenuItem?.title ?? "Товар",
        quantity: Number(ci.quantity || 1),
        unitPrice: round2(unitPrice),
        lineTotal: round2(lineTotal),
        optionIds: (ci.optionsJson as any)?.optionIds || [],
        image: ci.MenuItem?.imageUrl ?? null,
        categoryId: ci.MenuItem?.categoryId ?? null,
      };
    }) || [];

  const subtotal = mapped.reduce((s, it) => s + it.lineTotal, 0);

  // ✅ Service fee (still called deliveryFee in API for compatibility)
  const deliveryFee = mapped.length > 0 ? 2 : 0;

  // Promo discount
  let promoDiscount = 0;
  let promoError = null;

  if (cart.promoCode) {
    try {
      const validation = await validatePromo(cart.promoCode, subtotal, userId);
      promoDiscount = validation.discountAmount;
    } catch (err: any) {
      promoError = err.message;
      promoDiscount = 0;

      await supabase
        .from("Cart")
        .update({ promoCode: null })
        .eq("id", cart.id);
    }
  }

  // Loyalty points
  const { data: user } = await supabase
    .from("User")
    .select("loyaltyPoints")
    .eq("id", userId)
    .single();

  const availablePoints = user?.loyaltyPoints || 0;

  let pointsDiscount = 0;
  let finalAppliedPoints = 0;

  if (appliedPoints && appliedPoints > 0 && availablePoints > 0) {
    const remainingTotal = subtotal - promoDiscount;
    const maxPointsByOrder = Math.floor(remainingTotal * 0.3);

    let pointsToUse = Math.min(appliedPoints, availablePoints, maxPointsByOrder);

    // round to clean numbers (100)
    pointsToUse = Math.floor(pointsToUse / 100) * 100;

    if (pointsToUse >= 100) {
      pointsDiscount = pointsToUse;
      finalAppliedPoints = pointsToUse;
    }
  }

  const total = Math.max(
    0,
    subtotal - promoDiscount - pointsDiscount + deliveryFee
  );

  return {
    items: mapped,
    subtotal: round2(subtotal),
    discount: round2(promoDiscount),
    pointsDiscount: round2(pointsDiscount),
    deliveryFee: round2(deliveryFee), // still called deliveryFee for frontend compatibility
    total: round2(total),
    promoCode: cart.promoCode,
    promoError,
    appliedPoints: finalAppliedPoints,
    availablePoints: availablePoints,
  };
}

async function computeUnitPrice(menuItemId: number, optionIds: number[]) {
  const { data: item, error } = await supabase
    .from("MenuItem")
    .select("*")
    .eq("id", menuItemId)
    .single();

  if (error || !item) {
    throw { status: 404, message: "Menu item not found" };
  }

  let price = Number(item.basePrice);

  if (optionIds.length) {
    const { data: opts, error: optsError } = await supabase
      .from("MenuOption")
      .select("priceDelta")
      .in("id", optionIds);

    if (!optsError && opts) {
      price += opts.reduce((s: number, o: any) => s + Number(o.priceDelta), 0);
    }
  }

  return { price, title: item.title };
}

export async function addItem(
  userId: number,
  input: { itemId: number; quantity: number; optionIds?: number[] }
) {
  const { itemId } = input;
  const quantity = Math.max(1, input.quantity || 1);
  const optionIds = input.optionIds || [];

  const cart = await getOrCreateCart(userId);
  const { price } = await computeUnitPrice(itemId, optionIds);

  const unitPrice = round2(price);
  const lineTotal = round2(price * quantity);

  const { data: rows, error: exErr } = await supabase
    .from("CartItem")
    .select("*")
    .eq("cartId", cart.id)
    .eq("menuItemId", itemId);

  if (!exErr && rows && rows.length > 0) {
    const matched = rows.find((r: any) => {
      const rOpts: number[] = (r.optionsJson as any)?.optionIds || [];
      return sameNumberSets(rOpts, optionIds);
    });

    if (matched) {
      const newQty = Number(matched.quantity || 0) + quantity;
      const newTotal = round2(newQty * Number(matched.unitPriceSnapshot ?? unitPrice));
      const { error: upErr } = await supabase
        .from("CartItem")
        .update({ quantity: newQty, lineTotal: newTotal })
        .eq("id", matched.id);

      if (upErr) throw { status: 500, message: "Failed to update existing cart item" };

      await supabase
        .from("Cart")
        .update({ updatedAt: new Date().toISOString() })
        .eq("id", cart.id);

      return matched.id;
    }
  }

  const { data: created, error } = await supabase
    .from("CartItem")
    .insert({
      cartId: cart.id,
      menuItemId: itemId,
      quantity,
      unitPriceSnapshot: unitPrice,
      optionsJson: { optionIds },
      lineTotal,
    })
    .select()
    .single();

  if (error) {
    throw { status: 500, message: "Failed to add item to cart" };
  }

  await supabase
    .from("Cart")
    .update({ updatedAt: new Date().toISOString() })
    .eq("id", cart.id);

  return created.id;
}

export async function updateItemQuantity(
  userId: number,
  menuItemId: number,
  quantity: number
) {
  const cart = await getOrCreateCart(userId);

  const { data: rows, error: rowErr } = await supabase
    .from("CartItem")
    .select("*")
    .eq("cartId", cart.id)
    .eq("menuItemId", menuItemId);

  if (rowErr || !rows || rows.length === 0) {
    throw { status: 404, message: "Item not in cart" };
  }

  const first = rows[0];
  const totalQty = Math.max(0, quantity);
  const unitPrice = Number(first.unitPriceSnapshot ?? first.unitPrice ?? 0);

  if (totalQty <= 0) {
    const { error: delErr } = await supabase
      .from("CartItem")
      .delete()
      .eq("cartId", cart.id)
      .eq("menuItemId", menuItemId);
    if (delErr) throw { status: 500, message: "Failed to remove item" };
    return;
  }

  if (rows.length > 1) {
    const extraIds = rows.slice(1).map((r: any) => r.id);
    await supabase.from("CartItem").delete().in("id", extraIds);
  }

  const lineTotal = round2(unitPrice * totalQty);

  const { error: upErr } = await supabase
    .from("CartItem")
    .update({ quantity: totalQty, lineTotal })
    .eq("id", first.id);

  if (upErr) throw { status: 500, message: "Failed to update quantity" };

  await supabase
    .from("Cart")
    .update({ updatedAt: new Date().toISOString() })
    .eq("id", cart.id);
}

export async function removeByMenuItem(userId: number, menuItemId: number) {
  const cart = await getOrCreateCart(userId);

  const { error } = await supabase
    .from("CartItem")
    .delete()
    .eq("cartId", cart.id)
    .eq("menuItemId", menuItemId);

  if (error) throw { status: 500, message: "Failed to remove item from cart" };

  await supabase
    .from("Cart")
    .update({ updatedAt: new Date().toISOString() })
    .eq("id", cart.id);
}

export async function removeItem(userId: number, cartItemId: number) {
  const cart = await getOrCreateCart(userId);

  const { data: item, error: fetchError } = await supabase
    .from("CartItem")
    .select("*")
    .eq("id", cartItemId)
    .single();

  if (fetchError || !item || item.cartId !== cart.id) {
    throw { status: 404, message: "Cart item not found" };
  }

  const { error } = await supabase.from("CartItem").delete().eq("id", cartItemId);
  if (error) {
    throw { status: 500, message: "Failed to remove item from cart" };
  }
}

export async function applyPromo(userId: number, code: string) {
  const cart = await getOrCreateCart(userId);
  
  // First get current cart to get subtotal
  const currentCart = await getCart(userId);
  
  if (!code || code.trim() === "") {
    // Clear promo
    const { error: clearErr } = await supabase
      .from("Cart")
      .update({ promoCode: null })
      .eq("id", cart.id);
    if (clearErr) throw { status: 500, message: "Failed to clear promo" };
    return getCart(userId);
  }

  // Validate promo with current subtotal
  await validatePromo(code.toUpperCase(), currentCart.subtotal, userId);

  // Save promo on cart
  const { error: updateError } = await supabase
    .from("Cart")
    .update({ promoCode: code.toUpperCase() })
    .eq("id", cart.id);
    
  if (updateError) {
    throw { status: 500, message: "Failed to apply promo" };
  }

  return getCart(userId);
}

export async function clearCart(cartId: number) {
  await supabase.from("CartItem").delete().eq("cartId", cartId);
  await supabase.from("Cart").update({ promoCode: null }).eq("id", cartId);
}

export async function getCartRecord(userId: number) {
  return getOrCreateCart(userId);
}

export async function applyLoyaltyPoints(userId: number, pointsToApply: number) {
  const cart = await getOrCreateCart(userId);
  
  // Validate points
  const currentCart = await getCart(userId);
  const { data: user } = await supabase
    .from("User")
    .select("loyaltyPoints")
    .eq("id", userId)
    .single();
  
  const availablePoints = user?.loyaltyPoints || 0;
  const remainingTotal = currentCart.subtotal - currentCart.discount;
  const maxPointsByOrder = Math.floor(remainingTotal * 0.3);
  
  let finalPoints = Math.min(pointsToApply, availablePoints, maxPointsByOrder);
  finalPoints = Math.floor(finalPoints / 100) * 100;
  
  if (finalPoints < 100) {
    throw { status: 400, message: "Minimum 100 points required" };
  }
  
  // Store applied points in cart (you might want to add a column to Cart table)
  // For now, we'll just return the updated cart
  return getCart(userId, finalPoints);
}

// ✅ ADD NEW FUNCTION to remove loyalty points
export async function removeLoyaltyPoints(userId: number) {
  return getCart(userId, 0);
}