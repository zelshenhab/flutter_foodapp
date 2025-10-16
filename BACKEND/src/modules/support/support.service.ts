import { db, SupportMessage } from "../../core/config/db";

export function submitSupportMessage(data: Omit<SupportMessage, "id" | "createdAt">): SupportMessage {
  const id = `s_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 6)}`;
  const createdAt = new Date().toISOString();
  const message: SupportMessage = { id, createdAt, ...data };
  db.supports.push(message);
  return message;
}

