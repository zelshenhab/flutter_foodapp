import { Response } from "express";
import { AuthRequest } from "../../core/middlewares/auth.middleware";
import { createOrder, getOrderById, listOrders } from "./order.service";
import { CreateOrderRequest } from "./order.types";

export async function getOrders(req: AuthRequest, res: Response) {
  const userId = req.user!.userId;
  const data = await listOrders(userId);
  return res.json(data);
}

export async function getOrder(req: AuthRequest, res: Response) {
  const userId = req.user!.userId;
  const { orderId } = req.params;
  const order = await getOrderById(userId, orderId);
  if (!order) return res.status(404).json({ message: "Order not found" });
  return res.json(order);
}

export async function postOrder(req: AuthRequest, res: Response) {
  const userId = req.user!.userId;
  const body = req.body as CreateOrderRequest;
  if (!body?.items || !Array.isArray(body.items) || body.items.length === 0) {
    return res.status(400).json({ message: "items array is required" });
  }
  const created = await createOrder(userId, body);
  return res.status(201).json(created);
}

