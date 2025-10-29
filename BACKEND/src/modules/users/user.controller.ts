import { Request, Response } from "express";
import { verifyToken } from "../../core/utils/jwt";
import * as svc from "./user.service";

function userIdFrom(req: Request): number {
  const h = req.headers.authorization || "";
  const token = h.startsWith("Bearer ") ? h.slice(7) : "";
  if (!token) throw { status: 401, message: "Unauthorized" };
  const payload = verifyToken<{ id: number }>(token);
  return payload.id;
}

export async function getMe(req: Request, res: Response) {
  try {
    const userId = userIdFrom(req);
    const me = await svc.getMe(userId);
    res.json(me);
  } catch (err) {
    console.error(err);
    res.status((err as any)?.status || 500).json({ error: "Failed to get profile" });
  }
}

export async function updateMe(req: Request, res: Response) {
  try {
    const userId = userIdFrom(req);
    const { name, avatarUrl } = req.body || {};

    const patch: { name?: string; avatarUrl?: string | null } = {};
    if (typeof name === "string") patch.name = name;
    if (typeof avatarUrl === "string" || avatarUrl === null) patch.avatarUrl = avatarUrl;

    const updated = await svc.updateMe(userId, patch);
    res.json(updated);
  } catch (err) {
    console.error(err);
    res.status((err as any)?.status || 500).json({ error: "Failed to update profile" });
  }
}