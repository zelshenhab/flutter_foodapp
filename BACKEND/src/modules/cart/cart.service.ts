import { supabase } from "../../core/config/supabase";

type Pricing = {
  items: Array<{
    id: number;
    title: string;
    quantity: number;
    unitPrice: number;
    lineTotal: number;
    optionIds: number[];
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

async function getOrCreateCart(userId: number) {
  // Try to get existing cart
  const { data: existing, error: fetchError } = await supabase
    .from('Cart')
    .select('*')
    .eq('userId', userId)
    .single();

  if (existing && !fetchError) {
    return existing;
  }

  // Create new cart if doesn't exist
  const { data: newCart, error: createError } = await supabase
    .from('Cart')
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
    .from('CartItem')
    .select(`
      *,
      MenuItem!inner(*)
    `)
    .eq('cartId', cart.id)
    .order('id', { ascending: true });

  if (error) {
    throw { status: 500, message: "Failed to fetch cart items" };
  }

  const mapped = items?.map((ci) => {
    const unitPrice = Number(ci.unitPriceSnapshot);
    const lineTotal = Number(ci.lineTotal);
    return {
      id: ci.id,
      title: ci.MenuItem.title,
      quantity: ci.quantity,
      unitPrice,
      lineTotal,
      optionIds: (ci.optionsJson as any)?.optionIds || [],
    };
  }) || [];

  const subtotal = mapped.reduce((s, it) => s + it.lineTotal, 0);
  // simple delivery rule for now:
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
    .from('MenuItem')
    .select('*')
    .eq('id', menuItemId)
    .single();

  if (error || !item) {
    throw { status: 404, message: "Menu item not found" };
  }

  let price = Number(item.basePrice);

  if (optionIds.length) {
    const { data: opts, error: optsError } = await supabase
      .from('MenuOption')
      .select('priceDelta')
      .in('id', optionIds);

    if (!optsError && opts) {
      price += opts.reduce((s, o) => s + Number(o.priceDelta), 0);
    }
  }
  
  return { price, title: item.title };
}

export async function addItem(userId: number, input: { itemId: number; quantity: number; optionIds?: number[] }) {
  const { itemId } = input;
  const quantity = Math.max(1, input.quantity || 1);
  const optionIds = input.optionIds || [];

  const cart = await getOrCreateCart(userId);
  const { price } = await computeUnitPrice(itemId, optionIds);

  const unitPrice = round2(price);
  const lineTotal = round2(price * quantity);

  const { data: created, error } = await supabase
    .from('CartItem')
    .insert({
      cartId: cart.id,
      menuItemId: itemId,
      quantity,
      unitPriceSnapshot: unitPrice,
      optionsJson: { optionIds },
      lineTotal: lineTotal,
    })
    .select()
    .single();

  if (error) {
    throw { status: 500, message: "Failed to add item to cart" };
  }

  // update cart timestamp
  await supabase
    .from('Cart')
    .update({ updatedAt: new Date().toISOString() })
    .eq('id', cart.id);

  return created.id;
}

export async function removeItem(userId: number, cartItemId: number) {
  const cart = await getOrCreateCart(userId);
  
  const { data: item, error: fetchError } = await supabase
    .from('CartItem')
    .select('*')
    .eq('id', cartItemId)
    .single();

  if (fetchError || !item || item.cartId !== cart.id) {
    throw { status: 404, message: "Cart item not found" };
  }

  const { error } = await supabase
    .from('CartItem')
    .delete()
    .eq('id', cartItemId);

  if (error) {
    throw { status: 500, message: "Failed to remove item from cart" };
  }
}

export async function applyPromo(userId: number, code: string) {
  const cart = await getOrCreateCart(userId);
  
  // Validate promo exists & active
  const { data: promo, error } = await supabase
    .from('Promo')
    .select('*')
    .eq('code', code)
    .eq('active', true)
    .single();

  if (error || !promo) {
    throw { status: 400, message: "Invalid promo" };
  }

  // Save on cart
  const { error: updateError } = await supabase
    .from('Cart')
    .update({ promoCode: code })
    .eq('id', cart.id);

  if (updateError) {
    throw { status: 500, message: "Failed to apply promo" };
  }

  return getCart(userId);
}

async function computePromoDiscount(code: string, subtotal: number) {
  const { data: promo, error } = await supabase
    .from('Promo')
    .select('*')
    .eq('code', code)
    .eq('active', true)
    .single();

  if (error || !promo) return 0;

  // date window check
  const now = new Date();
  if ((promo.validFrom && new Date(promo.validFrom) > now) || 
      (promo.validTo && new Date(promo.validTo) < now)) {
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
  await supabase
    .from('CartItem')
    .delete()
    .eq('cartId', cartId);

  await supabase
    .from('Cart')
    .update({ promoCode: null })
    .eq('id', cartId);
}

export async function getCartRecord(userId: number) {
  return getOrCreateCart(userId);
}