// backend/src/modules/loyalty/loyalty.controller.ts
import { Request, Response } from "express";
import * as svc from "./loyalty.service";
import { verifyTokenSafe } from "../../../core/utils/jwt";

function getUserId(req: Request): number {
  const auth = req.headers.authorization || "";
  const token = auth.startsWith("Bearer ") ? auth.slice(7) : "";
  if (!token) throw { status: 401, message: "Unauthorized" };

  const { valid, payload } = verifyTokenSafe<{ id: number }>(token);
  if (!valid) throw { status: 401, message: "Invalid token" };
  return payload!.id;
}

export async function getLoyaltyInfo(req: Request, res: Response) {
  try {
    const userId = getUserId(req);
    const data = await svc.getUserLoyalty(userId);
    res.json({ data });
  } catch (err: any) {
    res.status(err?.status || 500).json({ 
      message: err?.message || "Failed to fetch loyalty info" 
    });
  }
}

export async function calculatePointsRedemption(req: Request, res: Response) {
  try {
    const userId = getUserId(req);
    const { cartTotal, requestedPoints } = req.body;
    
    const data = await svc.calculatePointsRedemption(cartTotal, requestedPoints, userId);
    res.json({ data });
  } catch (err: any) {
    res.status(err?.status || 500).json({ 
      message: err?.message || "Failed to calculate points" 
    });
  }
}

export async function redeemPoints(req: Request, res: Response) {
  try {
    const userId = getUserId(req);
    const { points, orderId } = req.body;
    
    const data = await svc.redeemLoyaltyPoints(userId, points, orderId);
    res.json({ data });
  } catch (err: any) {
    res.status(err?.status || 500).json({ 
      message: err?.message || "Failed to redeem points" 
    });
  }
}