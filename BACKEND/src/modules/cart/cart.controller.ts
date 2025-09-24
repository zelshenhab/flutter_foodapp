import { Request, Response } from "express";

export async function getCart(req: Request, res: Response) {
  res.json({ items: [] });
}
export async function addItem(req: Request, res: Response) {
  res.json({ message: "Item added to cart" });
}
