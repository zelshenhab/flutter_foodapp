import { Request, Response } from "express";
import * as svc from "./cart.service";
import { verifyToken } from "../../core/utils/jwt";

function userIdFrom(req: Request): number {
  const h = req.headers.authorization || "";
  const token = h.startsWith("Bearer ") ? h.slice(7) : "";
  if (!token) throw { status: 401, message: "Unauthorized" };
  const payload = verifyToken<{ id: number }>(token);
  return payload.id;
}

export async function getCart(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const data = await svc.getCart(userId);
  res.json({ data });
}

export async function addItem(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const { itemId, quantity, optionIds } = req.body || {};
  if (!itemId) return res.status(400).json({ error: "itemId is required" });
  const id = await svc.addItem(userId, { itemId: Number(itemId), quantity: Number(quantity || 1), optionIds: optionIds || [] });
  res.status(201).json({ id });
}

export async function removeItem(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const id = Number(req.params.id);
  await svc.removeItem(userId, id);
  res.status(204).send();
}

export async function applyPromo(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const { code } = req.body || {};
  if (!code) return res.status(400).json({ error: "code is required" });
  const data = await svc.applyPromo(userId, String(code));
  res.json({ data });
}
