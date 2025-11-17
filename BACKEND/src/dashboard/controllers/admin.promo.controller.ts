import { Request, Response, NextFunction } from "express";
import * as svc from "../services/admin.promo.service";

export async function listPromos(_req: Request, res: Response, next: NextFunction) {
  try {
    const data = await svc.listPromos();
    res.json({ data });
  } catch (err) {
    next(err);
  }
}

export async function createPromo(req: Request, res: Response, next: NextFunction) {
  try {
    const data = await svc.createPromo(req.body);
    res.status(201).json({ data });
  } catch (err) {
    next(err);
  }
}

export async function updatePromo(req: Request, res: Response, next: NextFunction) {
  try {
    const id = Number(req.params.id);
    const data = await svc.updatePromo(id, req.body);
    res.json({ data });
  } catch (err) {
    next(err);
  }
}

export async function deletePromo(req: Request, res: Response, next: NextFunction) {
  try {
    const id = Number(req.params.id);
    await svc.deletePromo(id);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
}
