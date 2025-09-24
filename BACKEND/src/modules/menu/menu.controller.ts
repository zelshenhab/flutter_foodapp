import { Request, Response } from "express";

export async function getCategories(req: Request, res: Response) {
  res.json([{ id: 1, title: "Shawarma" }]);
}
export async function getItems(req: Request, res: Response) {
  res.json([{ id: 101, title: "Chicken Shawarma", price: 5.99 }]);
}
