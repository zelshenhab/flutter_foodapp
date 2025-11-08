import { Request, Response } from "express";
import * as svc from "./order.service";
import { verifyTokenSafe } from "../../../core/utils/jwt";

function userIdFrom(req: Request): number {
  const auth = req.headers.authorization || "";
  const token = auth.startsWith("Bearer ") ? auth.slice(7) : "";
  if (!token) throw { status: 401, message: "Unauthorized" };

  const { valid, expired, payload } = verifyTokenSafe<{ id: number }>(token);
  if (!valid) throw { status: 401, message: expired ? "Token expired" : "Invalid token" };
  return payload!.id;
}

export async function previewOrder(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const data = await svc.preview(userId);
  res.json({ data });
}

export async function createOrder(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const { paymentMethod, address, notes } = req.body || {};
  if (!paymentMethod) throw { status: 400, message: "paymentMethod is required" };

  const data = await svc.createOrder(userId, { paymentMethod, address, notes });
  res.status(201).json(data);
}

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

export async function completeOrder(req: Request, res: Response) {
  const userId = userIdFrom(req);
  const id = Number(req.params.id);
  const data = await svc.completeOrder(userId, id);
  res.json({ data });
}
