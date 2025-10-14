import { Request, Response } from "express";
import { getCategories, getItemsByCategory, getMenuItem } from "./menu.service";

export function listCategories(_req: Request, res: Response) {
  return res.json(getCategories());
}

export function listItemsByCategory(req: Request, res: Response) {
  const { categoryId } = req.params;
  if (!categoryId) return res.status(400).json({ message: "categoryId is required" });
  return res.json(getItemsByCategory(categoryId));
}

export function getItem(req: Request, res: Response) {
  const { itemId } = req.params;
  if (!itemId) return res.status(400).json({ message: "itemId is required" });
  const item = getMenuItem(itemId);
  if (!item) return res.status(404).json({ message: "Item not found" });
  return res.json(item);
}

