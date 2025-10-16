import { Request, Response } from "express";
import { getCategories, getItemsByCategory, getMenuItem } from "./menu.service";

export async function listCategories(_req: Request, res: Response) {
  const data = await getCategories();
  return res.json(data);
}

export async function listItemsByCategory(req: Request, res: Response) {
  const { categoryId } = req.params;
  if (!categoryId) return res.status(400).json({ message: "categoryId is required" });
  const data = await getItemsByCategory(categoryId);
  return res.json(data);
}

export async function getItem(req: Request, res: Response) {
  const { itemId } = req.params;
  if (!itemId) return res.status(400).json({ message: "itemId is required" });
  const item = await getMenuItem(itemId);
  if (!item) return res.status(404).json({ message: "Item not found" });
  return res.json(item);
}

