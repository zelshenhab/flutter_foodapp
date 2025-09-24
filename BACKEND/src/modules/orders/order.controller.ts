import { Request, Response } from "express";

export async function listOrders(req: Request, res: Response) {
  res.json([{ id: 9001, status: "pending" }]);
}
export async function getOrder(req: Request, res: Response) {
  res.json({ id: req.params.id, status: "pending" });
}
