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
  const { itemId, quantity, optionIds } = (req.body || {}) as {
    itemId?: number;
    quantity?: number;
    optionIds?: number[];
  };

  if (!itemId) return res.status(400).json({ error: "itemId is required" });

  const id = await svc.addItem(userId, {
    itemId: Number(itemId),
    quantity: Number(quantity || 1),
    optionIds: optionIds || [],
  });

  // Return just created id; frontend usually refreshes cart after add
  res.status(201).json({ id });
}

// NEW: set absolute quantity for a menu item in user's cart (<=0 removes)
export async function updateItemQty(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const { itemId, quantity } = (req.body || {}) as {
    itemId?: number;
    quantity?: number;
  };

  if (!itemId || quantity === undefined || quantity === null) {
    return res
      .status(400)
      .json({ error: "itemId and quantity are required" });
  }

  await svc.updateItemQuantity(userId, Number(itemId), Number(quantity));

  // Return fresh cart
  const data = await svc.getCart(userId);
  res.json({ data });
}

// UPDATED: remove by menu item id (not by CartItem id)
export async function removeItem(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const itemId = Number(req.params.itemId);
  if (!itemId) return res.status(400).json({ error: "Invalid itemId" });

  await svc.removeByMenuItem(userId, itemId);

  // Return fresh cart so UI can update immediately
  const data = await svc.getCart(userId);
  res.json({ data });
}

export async function applyPromo(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const { code } = (req.body || {}) as { code?: string };

  // Allow clearing promo when code is empty string
  const data = await svc.applyPromo(userId, String(code || ""));
  res.json({ data });
}
