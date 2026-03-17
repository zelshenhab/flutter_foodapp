import { supabase } from "../../../core/config/supabase";
import * as cartSvc from "../cart/cart.service";

/* ======================================================
   HELPERS
====================================================== */

function getMenuItem(ci: any) {
  if (!ci.MenuItem || typeof ci.MenuItem !== "object") {
    throw {
      status: 400,
      message: "One or more items are no longer available",
    };
  }

  return ci.MenuItem;
}

/* ======================================================
   PREVIEW
====================================================== */

export async function preview(userId: number) {
  return cartSvc.getCart(userId);
}

/* ======================================================
   CREATE ORDER
====================================================== */

export async function createOrder(
  userId: number,
  input: {
    paymentMethod: "cod" | "card";
    address: any;
    notes?: string;
  }
) {
  /* -----------------------------------------
   * 1️⃣ LOAD CART
   * --------------------------------------- */

  const cartRec = await cartSvc.getCartRecord(userId);
  const cart = await cartSvc.getCart(userId);

  console.log("USER ID:", userId);
  console.log("CREATE ORDER INPUT:", input);
  console.log("CART:", cart);

  if (!cart.items.length) {
    throw { status: 400, message: "Cart is empty" };
  }

  /* -----------------------------------------
   * 2️⃣ CREATE ORDER
   * --------------------------------------- */

  const { data: order, error: orderError } = await supabase
    .from("Order")
    .insert({
      userId,
      status: "pending",
      paymentMethod: input.paymentMethod,
      paymentStatus: input.paymentMethod === "cod" ? "unpaid" : "pending",
      subtotal: cart.subtotal,
      discount: cart.discount,
      deliveryFee: cart.deliveryFee,
      total: cart.total,
      addressSnapshot: input.address ?? { text: "N/A" },
      promoCode: cart.promoCode ?? null,
      notes: input.notes ?? null,
    })
    .select()
    .single();

  if (orderError || !order) {
    console.error("❌ ORDER INSERT ERROR:", orderError);
    throw { status: 500, message: "Failed to create order" };
  }

  /* -----------------------------------------
   * 3️⃣ LOAD CART ITEMS
   * --------------------------------------- */

  const { data: cartItems, error: cartItemsError } = await supabase
    .from("CartItem")
    .select(
      `
      id,
      menuItemId,
      quantity,
      unitPriceSnapshot,
      lineTotal,
      MenuItem (
        id,
        title
      )
    `
    )
    .eq("cartId", cartRec.id)
    .order("id", { ascending: true });
    console.log("CART ITEMS:", cartItems);

  if (cartItemsError || !cartItems?.length) {
    console.error("❌ CART ITEMS ERROR:", cartItemsError);
    throw { status: 500, message: "Failed to fetch cart items" };
  }

  /* -----------------------------------------
   * 4️⃣ CREATE ORDER ITEMS
   * --------------------------------------- */

  const orderItems = cartItems.map((ci) => {
    const menuItem = getMenuItem(ci);

    return {
      orderId: order.id,
      menuItemId: ci.menuItemId,
      titleSnap: menuItem.title,
      unitPrice: Number(ci.unitPriceSnapshot),
      quantity: ci.quantity,
      lineTotal: Number(ci.lineTotal),
    };
  });

  const { error: orderItemsError } = await supabase
    .from("OrderItem")
    .insert(orderItems);

  if (orderItemsError) {
    console.error("❌ ORDER ITEMS ERROR:", orderItemsError);
    throw { status: 500, message: "Failed to create order items" };
  }

  console.log("ORDER ITEMS CREATED:", orderItems);

  console.log("CLEARING CART:", cartRec.id);
  /* -----------------------------------------
   * 5️⃣ CLEAR CART
   * --------------------------------------- */

  await cartSvc.clearCart(cartRec.id);

  return {
    orderId: order.id,
    status: order.status,
    total: Number(order.total),
  };
}

/* ======================================================
   LIST ORDERS
====================================================== */

export async function listOrders(
  userId: number,
  opts: { status?: string; page?: number; limit?: number }
) {
  const page = Math.max(1, Number(opts.page || 1));
  const limit = Math.min(50, Math.max(1, Number(opts.limit || 10)));
  const offset = (page - 1) * limit;

  let query = supabase
    .from("Order")
    .select("*")
    .eq("userId", userId)
    .order("createdAt", { ascending: false })
    .range(offset, offset + limit - 1);

  if (opts.status) query = query.eq("status", opts.status);

  const { data, error } = await query;

  if (error) {
    console.error("❌ LIST ORDERS ERROR:", error);
    throw { status: 500, message: "Failed to fetch orders" };
  }

  return data ?? [];
}

/* ======================================================
   GET ORDER DETAIL
====================================================== */

export async function getOrderDetail(userId: number, orderId: number) {
  const { data: order, error } = await supabase
    .from("Order")
    .select("*")
    .eq("id", orderId)
    .eq("userId", userId)
    .single();

  if (error || !order) {
    throw { status: 404, message: "Order not found" };
  }

  const { data: items } = await supabase
    .from("OrderItem")
    .select("*")
    .eq("orderId", orderId);

  return { ...order, items: items ?? [] };
}

/* ======================================================
   COMPLETE ORDER
====================================================== */

export async function completeOrder(userId: number, orderId: number) {
  const { data, error } = await supabase
    .from("Order")
    .update({ status: "completed" })
    .eq("id", orderId)
    .eq("userId", userId)
    .select()
    .single();

  if (error || !data) {
    console.error("❌ COMPLETE ORDER ERROR:", error);
    throw { status: 500, message: "Failed to complete order" };
  }

  return data;
}