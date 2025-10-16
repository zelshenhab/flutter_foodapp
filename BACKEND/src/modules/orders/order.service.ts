import { db, Order } from "../../core/config/db";
import { supabase } from "../../core/config/supabase";
import { CreateOrderRequest } from "./order.types";

export async function listOrders(userId: string): Promise<Order[]> {
  if (supabase) {
    const { data, error } = await supabase
      .from("orders")
      .select("id,user_id,created_at,restaurant,delivery_fee,discount,status,order_items(id,item_id,name,price,qty,image)")
      .eq("user_id", userId)
      .order("created_at", { ascending: false });
    if (!error && data) {
      return data.map((o: any) => ({
        id: o.id,
        userId: o.user_id,
        createdAt: o.created_at,
        restaurant: o.restaurant,
        items: (o.order_items || []).map((it: any) => ({ id: it.item_id, name: it.name, price: Number(it.price), qty: it.qty, image: it.image })),
        deliveryFee: Number(o.delivery_fee),
        discount: Number(o.discount),
        status: o.status,
      }));
    }
  }
  return db.orders.get(userId) ?? [];
}

export async function getOrderById(userId: string, orderId: string): Promise<Order | null> {
  if (supabase) {
    const { data, error } = await supabase
      .from("orders")
      .select("id,user_id,created_at,restaurant,delivery_fee,discount,status,order_items(id,item_id,name,price,qty,image)")
      .eq("user_id", userId)
      .eq("id", orderId)
      .maybeSingle();
    if (!error && data) {
      return {
        id: data.id,
        userId: data.user_id,
        createdAt: data.created_at,
        restaurant: data.restaurant,
        items: (data.order_items || []).map((it: any) => ({ id: it.item_id, name: it.name, price: Number(it.price), qty: it.qty, image: it.image })),
        deliveryFee: Number(data.delivery_fee),
        discount: Number(data.discount),
        status: data.status,
      };
    }
  }
  const list = db.orders.get(userId) ?? [];
  return list.find((o) => o.id === orderId) ?? null;
}

export async function createOrder(userId: string, payload: CreateOrderRequest): Promise<Order> {
  const id = `ord_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 6)}`;
  const createdAt = new Date().toISOString();
  const order: Order = {
    id,
    userId,
    createdAt,
    restaurant: "Адам и Ева",
    items: payload.items.map((i) => ({ id: i.id, name: i.name, price: i.price, qty: i.qty, image: i.image })),
    deliveryFee: payload.deliveryFee ?? 0,
    discount: payload.discount ?? 0,
    status: "pending",
  };
  if (supabase) {
    const { error: orderErr } = await supabase.from("orders").insert({
      id: order.id,
      user_id: order.userId,
      created_at: order.createdAt,
      restaurant: order.restaurant,
      delivery_fee: order.deliveryFee,
      discount: order.discount,
      status: order.status,
    });
    if (!orderErr) {
      const rows = order.items.map((it) => ({
        order_id: order.id,
        item_id: it.id,
        name: it.name,
        price: it.price,
        qty: it.qty,
        image: it.image,
      }));
      const { error: itemsErr } = await supabase.from("order_items").insert(rows);
      if (!itemsErr) return order;
    }
  }
  const list = db.orders.get(userId) ?? [];
  list.unshift(order);
  db.orders.set(userId, list);
  return order;
}

