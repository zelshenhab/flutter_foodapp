import { supabase } from "../../../core/config/supabase";

type Pricing = {
  items: Array<{
    id: number;          // menuItemId (numeric) to make FE ops easy
    title: string;
    quantity: number;
    unitPrice: number;
    lineTotal: number;
    optionIds: number[];
    menuItemId: number;  // explicit too
    image?: string | null;
    categoryId?: string | null;
  }>;
  subtotal: number;
  discount: number;
  deliveryFee: number;
  total: number;
  promoCode?: string | null;
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
  // Try to get existing cart
  const { data: existing, error: fetchError } = await supabase
    .from("Cart")
    .select("*")
    .eq("userId", userId)
    .single();

  if (existing && !fetchError) {
    return existing;
  }

  // Create new cart if doesn't exist
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

export async function getCart(userId: number): Promise<Pricing> {
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

      // IMPORTANT: expose id = menuItemId to keep FE numeric id easy
      return {
        id: ci.menuItemId, // <= menuItemId (numeric)
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
  const deliveryFee = subtotal > 0 ? 1.5 : 0;

  let discount = 0;
  if (cart.promoCode) {
    discount = await computePromoDiscount(cart.promoCode, subtotal);
  }
  const total = Math.max(0, subtotal - discount + deliveryFee);

  return {
    items: mapped,
    subtotal: round2(subtotal),
    discount: round2(discount),
    deliveryFee: round2(deliveryFee),
    total: round2(total),
    promoCode: cart.promoCode,
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

  // 🔁 Try to merge with an existing line that has SAME menuItemId AND SAME optionIds
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

  // ➕ Else insert new line
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

  // touch cart
  await supabase
    .from("Cart")
    .update({ updatedAt: new Date().toISOString() })
    .eq("id", cart.id);

  return created.id;
}

// NEW: set absolute quantity; if qty <= 0 remove the line
export async function updateItemQuantity(
  userId: number,
  menuItemId: number,
  quantity: number
) {
  const cart = await getOrCreateCart(userId);

  // get all matching rows (not single)
  const { data: rows, error: rowErr } = await supabase
    .from("CartItem")
    .select("*")
    .eq("cartId", cart.id)
    .eq("menuItemId", menuItemId);

  if (rowErr || !rows || rows.length === 0) {
    throw { status: 404, message: "Item not in cart" };
  }

  // merge all duplicates into one by deleting extras
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

  // delete duplicates except one
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

// NEW: remove by menu item id for this user's cart
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

// OLD: remove by CartItem id (kept for completeness; not used by new controller)
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

  if (!code) {
    // clear promo
    const { error: clearErr } = await supabase
      .from("Cart")
      .update({ promoCode: null })
      .eq("id", cart.id);
    if (clearErr) throw { status: 500, message: "Failed to clear promo" };
    return getCart(userId);
  }

  // Validate promo exists & active
  const { data: promo, error } = await supabase
    .from("Promo")
    .select("*")
    .eq("code", code)
    .eq("active", true)
    .single();

  if (error || !promo) {
    throw { status: 400, message: "Invalid promo" };
  }

  // Save on cart
  const { error: updateError } = await supabase
    .from("Cart")
    .update({ promoCode: code })
    .eq("id", cart.id);
  if (updateError) {
    throw { status: 500, message: "Failed to apply promo" };
  }

  return getCart(userId);
}

async function computePromoDiscount(code: string, subtotal: number) {
  const { data: promo, error } = await supabase
    .from("Promo")
    .select("*")
    .eq("code", code)
    .eq("active", true)
    .single();

  if (error || !promo) return 0;

  // date window check
  const now = new Date();
  if (
    (promo.validFrom && new Date(promo.validFrom) > now) ||
    (promo.validTo && new Date(promo.validTo) < now)
  ) {
    return 0;
  }

  if (promo.minSubtotal && Number(promo.minSubtotal) > subtotal) return 0;

  const type = promo.type;
  const value = Number(promo.value);
  if (type === "percent") {
    return round2((value / 100) * subtotal);
  }
  if (type === "fixed") {
    return Math.min(round2(value), subtotal);
  }
  return 0;
}

export async function clearCart(cartId: number) {
  await supabase.from("CartItem").delete().eq("cartId", cartId);
  await supabase.from("Cart").update({ promoCode: null }).eq("id", cartId);
}

export async function getCartRecord(userId: number) {
  return getOrCreateCart(userId);
}
