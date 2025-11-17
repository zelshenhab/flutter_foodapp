// BACKEND/src/dashboard/controllers/admin.menu.controller.ts

import { Request, Response, NextFunction } from "express";
import * as svc from "../services/admin.menu.service";

/* ========= CATEGORIES ========= */

export async function listCategories(_req: Request, res: Response, next: NextFunction) {
  try {
    const data = await svc.listCategories();
    res.json({ data });
  } catch (err) {
    next(err);
  }
}

export async function createCategory(req: Request, res: Response, next: NextFunction) {
  try {
    const data = await svc.createCategory(req.body);
    res.status(201).json({ data });
  } catch (err) {
    next(err);
  }
}

export async function updateCategory(req: Request, res: Response, next: NextFunction) {
  try {
    const id = Number(req.params.id);
    const data = await svc.updateCategory(id, req.body);
    res.json({ data });
  } catch (err) {
    next(err);
  }
}

export async function deleteCategory(req: Request, res: Response, next: NextFunction) {
  try {
    const id = Number(req.params.id);
    await svc.deleteCategory(id);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
}

/* ========= MENU ITEMS ========= */

export async function listItems(req: Request, res: Response, next: NextFunction) {
  try {
    const { categoryId, search, isActive } = req.query;

    const data = await svc.listItems({
      categoryId: categoryId ? Number(categoryId) : undefined,
      search: search ? String(search) : undefined,
      isActive:
        typeof isActive === "string"
          ? isActive.toLowerCase() === "true"
          : undefined,
    });

    res.json({ data });
  } catch (err) {
    next(err);
  }
}

export async function createItem(req: Request, res: Response, next: NextFunction) {
  try {
    const data = await svc.createItem(req.body);
    res.status(201).json({ data });
  } catch (err) {
    next(err);
  }
}

export async function updateItem(req: Request, res: Response, next: NextFunction) {
  try {
    const id = Number(req.params.id);
    const data = await svc.updateItem(id, req.body);
    res.json({ data });
  } catch (err) {
    next(err);
  }
}

export async function deleteItem(req: Request, res: Response, next: NextFunction) {
  try {
    const id = Number(req.params.id);
    await svc.deleteItem(id);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
}
