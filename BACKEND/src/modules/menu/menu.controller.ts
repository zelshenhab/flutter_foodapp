import { Request, Response } from "express";
import * as svc from "./menu.service";

export async function getCategories(_req: Request, res: Response) {
  const data = await svc.listCategories();
  res.json({ data });
}

export async function getItems(req: Request, res: Response) {
  const { category, search } = req.query as { category?: string; search?: string };
  const data = await svc.listItems({ categorySlug: category, search });
  res.json({ data });
}
