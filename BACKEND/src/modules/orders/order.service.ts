import { db, Order } from "../../core/config/db";
import { CreateOrderRequest } from "./order.types";

export function listOrders(userId: string): Order[] {
  return db.orders.get(userId) ?? [];
}

export function getOrderById(userId: string, orderId: string): Order | null {
  const list = db.orders.get(userId) ?? [];
  return list.find((o) => o.id === orderId) ?? null;
}

export function createOrder(userId: string, payload: CreateOrderRequest): Order {
  const id = `ord_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 6)}`;
  const next: Order = {
    id,
    userId,
    createdAt: new Date().toISOString(),
    restaurant: "Адам и Ева",
    items: payload.items.map((i) => ({ id: i.id, name: i.name, price: i.price, qty: i.qty, image: i.image })),
    deliveryFee: payload.deliveryFee ?? 0,
    discount: payload.discount ?? 0,
    status: "pending",
  };
  const list = db.orders.get(userId) ?? [];
  list.unshift(next);
  db.orders.set(userId, list);
  return next;
}

