import { db, SupportMessage } from "../../core/config/db";
import { supabase } from "../../core/config/supabase";

export async function submitSupportMessage(data: Omit<SupportMessage, "id" | "createdAt">): Promise<SupportMessage> {
  const id = `s_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 6)}`;
  const createdAt = new Date().toISOString();
  const message: SupportMessage = { id, createdAt, ...data };
  if (supabase) {
    const { error } = await supabase.from("support_messages").insert({
      id: message.id,
      user_id: message.userId ?? null,
      phone: message.phone ?? null,
      subject: message.subject,
      message: message.message,
      created_at: message.createdAt,
    });
    if (!error) return message;
  }
  db.supports.push(message);
  return message;
}

