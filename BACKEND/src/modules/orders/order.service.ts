import { supabase } from "../../core/config/supabase";
import * as cartSvc from "../cart/cart.service";

/** -------- Already implemented (Phase 3) ---------- */
type Preview = {
  subtotal: number;
  discount: number;
  deliveryFee: number;
  total: number;
  promoCode?: string | null;
  items: Array<{
    title: string;
    quantity: number;
    unitPrice: number;
    lineTotal: number;
  }>;
};

export async function preview(userId: number): Promise<Preview> {
  return cartSvc.getCart(userId);
}

export async function createOrder(
  userId: number,
  input: {
    paymentMethod: "cod" | "card";
    address: any;
    notes?: string;
  }
) {
  const cartRec = await cartSvc.getCartRecord(userId);
  const cart = await cartSvc.getCart(userId);
  if (cart.items.length === 0) throw { status: 400, message: "Cart is empty" };

  // Create order
  const { data: order, error: orderError } = await supabase
    .from('Order')
    .insert({
      userId,
      status: "pending",
      paymentMethod: input.paymentMethod,
      paymentStatus: input.paymentMethod === "cod" ? "unpaid" : "pending",
      subtotal: cart.subtotal,
      discount: cart.discount,
      deliveryFee: cart.deliveryFee,
      total: cart.total,
      addressSnapshot: input.address || { text: "N/A" },
      promoCode: cart.promoCode || null,
      notes: input.notes || null,
    })
    .select()
    .single();

  if (orderError) {
    throw { status: 500, message: "Failed to create order" };
  }

  // Get cart items with menu items
  const { data: cartItems, error: cartItemsError } = await supabase
    .from('CartItem')
    .select(`
      *,
      MenuItem!inner(*)
    `)
    .eq('cartId', cartRec.id)
    .order('id', { ascending: true });

  if (cartItemsError) {
    throw { status: 500, message: "Failed to fetch cart items" };
  }

  // Create order items
  const orderItems = cartItems?.map(ci => ({
    orderId: order.id,
    menuItemId: ci.menuItemId,
    titleSnap: ci.MenuItem.title,
    optionsSnap: ci.optionsJson,
    unitPrice: Number(ci.unitPriceSnapshot),
    quantity: ci.quantity,
    lineTotal: Number(ci.lineTotal),
  })) || [];

  if (orderItems.length > 0) {
    const { error: orderItemsError } = await supabase
      .from('OrderItem')
      .insert(orderItems);

    if (orderItemsError) {
      throw { status: 500, message: "Failed to create order items" };
    }
  }

  // Clear cart
  await cartSvc.clearCart(cartRec.id);

  return { orderId: order.id, status: order.status, total: Number(order.total) };
}

/** -------- New: list & details (Phase 4) ---------- */

export async function listOrders(
  userId: number,
  opts: { status?: string; page?: number; limit?: number }
) {
  const page = Math.max(1, Number(opts.page || 1));
  const limit = Math.min(50, Math.max(1, Number(opts.limit || 10)));
  const offset = (page - 1) * limit;

  let query = supabase
    .from('Order')
    .select('*')
    .eq('userId', userId)
    .order('createdAt', { ascending: false })
    .range(offset, offset + limit - 1);

  if (opts.status) {
    query = query.eq('status', opts.status);
  }

  const { data: rows, error } = await query;

  if (error) {
    throw { status: 500, message: "Failed to fetch orders" };
  }

  // Get total count
  let countQuery = supabase
    .from('Order')
    .select('*', { count: 'exact', head: true })
    .eq('userId', userId);

  if (opts.status) {
    countQuery = countQuery.eq('status', opts.status);
  }

  const { count: totalCount, error: countError } = await countQuery;

  if (countError) {
    throw { status: 500, message: "Failed to count orders" };
  }

  return {
    data: rows?.map((o) => ({
      ...o,
      total: Number(o.total),
      subtotal: Number(o.subtotal),
      discount: Number(o.discount),
      deliveryFee: Number(o.deliveryFee),
    })) || [],
    page,
    limit,
    totalCount: totalCount || 0,
    totalPages: Math.ceil((totalCount || 0) / limit),
  };
}

export async function getOrderDetail(userId: number, orderId: number) {
  const { data: order, error } = await supabase
    .from('Order')
    .select(`
      *,
      OrderItem(*)
    `)
    .eq('id', orderId)
    .eq('userId', userId)
    .single();

  if (error || !order) {
    throw { status: 404, message: "Order not found" };
  }

  type OrderItemRow = {
    unitPrice: number | string;
    lineTotal: number | string;
    // keep all other columns (ids, snapshots, etc.)
    [key: string]: any;
  };

  return {
    ...order,
    total: Number(order.total),
    subtotal: Number(order.subtotal),
    discount: Number(order.discount),
    deliveryFee: Number(order.deliveryFee),
    items: (order.OrderItem ?? []).map((it: OrderItemRow) => ({
      ...it,
      unitPrice: Number(it.unitPrice),
      lineTotal: Number(it.lineTotal),
    })),
  };
}
