// Simple in-memory data store for demo purposes. Replace with real DB later.

export type LanguageCode = "ru" | "en" | "ar" | string;

export interface UserProfile {
  userId: string;
  name: string;
  phone: string;
  email?: string;
  address: string;
  notifications: boolean;
  languageCode: LanguageCode;
  avatarPath?: string;
}

export interface OrderItem {
  id: string; // menu item id
  name: string;
  price: number;
  qty: number;
  image: string;
}

export type OrderStatus = "pending" | "preparing" | "onTheWay" | "delivered" | "cancelled";

export interface Order {
  id: string;
  userId: string;
  createdAt: string; // ISO string
  restaurant: string;
  items: OrderItem[];
  deliveryFee: number;
  discount: number;
  status: OrderStatus;
}

export interface SupportMessage {
  id: string;
  userId?: string;
  phone?: string;
  subject: string;
  message: string;
  createdAt: string;
}

export interface DataStore {
  users: Map<string, UserProfile>;
  otps: Map<string, string>; // phone -> code
  orders: Map<string, Order[]>; // userId -> orders
  supports: SupportMessage[];
}

export const db: DataStore = {
  users: new Map<string, UserProfile>(),
  otps: new Map<string, string>(),
  orders: new Map<string, Order[]>(),
  supports: [],
};

export function ensureUserByPhone(phone: string): UserProfile {
  // derive a deterministic userId from phone for demo
  const userId = `u_${phone.replace(/\D/g, "") || Math.random().toString(36).slice(2)}`;
  const existing = db.users.get(userId);
  if (existing) return existing;
  const profile: UserProfile = {
    userId,
    name: "User",
    phone,
    address: "ул. Пушкина 15",
    notifications: true,
    languageCode: "ru",
  };
  db.users.set(userId, profile);
  if (!db.orders.has(userId)) db.orders.set(userId, []);
  return profile;
}

