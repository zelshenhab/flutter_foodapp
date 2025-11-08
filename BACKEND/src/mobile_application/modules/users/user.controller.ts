import { Request, Response } from "express";
import { verifyTokenSafe } from "../../../core/utils/jwt";
import * as svc from "./user.service";

function userIdFrom(req: Request): number {
  const auth = req.headers.authorization || "";
  const token = auth.startsWith("Bearer ") ? auth.slice(7) : "";
  if (!token) throw { status: 401, message: "Unauthorized" };

  const { valid, expired, payload } = verifyTokenSafe<{ id: number }>(token);
  if (!valid) throw { status: 401, message: expired ? "Token expired" : "Invalid token" };
  return payload!.id;
}

export async function getMe(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const me = await svc.getMe(userId);
  res.json(me);
}

export async function updateMe(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const { name, avatarUrl } = req.body || {};

  const patch: { name?: string; avatarUrl?: string | null } = {};
  if (typeof name === "string") patch.name = name;
  if (typeof avatarUrl === "string" || avatarUrl === null) patch.avatarUrl = avatarUrl;

  const updated = await svc.updateMe(userId, patch);
  res.json(updated);
}
