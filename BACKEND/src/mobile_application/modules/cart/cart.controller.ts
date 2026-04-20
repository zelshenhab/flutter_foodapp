import { Request, Response } from "express";
import * as svc from "./cart.service";
import { verifyTokenSafe } from "../../../core/utils/jwt";

function userIdFrom(req: Request): number {
  const auth = req.headers.authorization || "";
  const token = auth.startsWith("Bearer ") ? auth.slice(7) : "";
  if (!token) throw { status: 401, message: "Unauthorized" };

  const { valid, expired, payload } = verifyTokenSafe<{ id: number }>(token);
  if (!valid) throw { status: 401, message: expired ? "Token expired" : "Invalid token" };
  return payload!.id;
}

export async function getCart(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const data = await svc.getCart(userId);
  res.json({ data });
}

export async function addItem(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const { itemId, quantity, optionIds } = req.body || {};

  if (!itemId) throw { status: 400, message: "itemId is required" };

  const id = await svc.addItem(userId, {
    itemId: Number(itemId),
    quantity: Number(quantity || 1),
    optionIds: optionIds || [],
  });

  res.status(201).json({ id });
}

export async function updateItemQty(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const { itemId, quantity } = req.body || {};

  if (!itemId || quantity === undefined)
    throw { status: 400, message: "itemId and quantity are required" };

  await svc.updateItemQuantity(userId, Number(itemId), Number(quantity));
  const data = await svc.getCart(userId);
  res.json({ data });
}

export async function removeItem(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const itemId = Number(req.params.itemId);
  if (!itemId) throw { status: 400, message: "Invalid itemId" };

  await svc.removeByMenuItem(userId, itemId);
  const data = await svc.getCart(userId);
  res.json({ data });
}

export async function applyPromo(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const { code } = req.body || {};
  const data = await svc.applyPromo(userId, String(code || ""));
  res.json({ data });
}

export async function applyLoyaltyPoints(req: Request, res: Response) {
  try {
    const userId = userIdFrom(req);
    const { points } = req.body;
    
    if (!points || points < 100) {
      return res.status(400).json({ message: "Minimum 100 points required" });
    }
    
    const data = await svc.applyLoyaltyPoints(userId, points);
    res.json({ data });
  } catch (err: any) {
    res.status(err?.status || 500).json({ 
      message: err?.message || "Failed to apply loyalty points" 
    });
  }
}

export async function removeLoyaltyPoints(req: Request, res: Response) {
  try {
    const userId = userIdFrom(req);
    const data = await svc.removeLoyaltyPoints(userId);
    res.json({ data });
  } catch (err: any) {
    res.status(err?.status || 500).json({ 
      message: err?.message || "Failed to remove loyalty points" 
    });
  }
}