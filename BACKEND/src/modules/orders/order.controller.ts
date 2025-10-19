import { Request, Response } from "express";
import * as svc from "./order.service";
import { verifyToken } from "../../core/utils/jwt";

function userIdFrom(req: Request): number {
  const h = req.headers.authorization || "";
  const token = h.startsWith("Bearer ") ? h.slice(7) : "";
  if (!token) throw { status: 401, message: "Unauthorized" };
  const payload = verifyToken<{ id: number }>(token);
  return payload.id;
}

// Phase 3 (existing)
export async function previewOrder(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const data = await svc.preview(userId);
  res.json({ data });
}

export async function createOrder(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const { paymentMethod, address, notes } = req.body || {};
  if (!paymentMethod) return res.status(400).json({ error: "paymentMethod is required" });
  const data = await svc.createOrder(userId, { paymentMethod, address, notes });
  res.status(201).json(data);
}

// Phase 4 (new)
export async function listMyOrders(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const { status, page, limit } = req.query as { status?: string; page?: string; limit?: string };
  const data = await svc.listOrders(userId, {
    status,
    page: page ? Number(page) : undefined,
    limit: limit ? Number(limit) : undefined,
  });
  res.json(data);
}

export async function getMyOrder(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const id = Number(req.params.id);
  const data = await svc.getOrderDetail(userId, id);
  res.json({ data });
}
