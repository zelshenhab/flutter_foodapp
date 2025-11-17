import { Request, Response, NextFunction } from "express";
import * as svc from "../services/admin.order.service";

export async function listOrders(req: Request, res: Response, next: NextFunction) {
  try {
    const { status, page, limit } = req.query;
    const data = await svc.listOrders({
      status: status ? String(status) : undefined,
      page: page ? Number(page) : 1,
      limit: limit ? Number(limit) : 20,
    });
    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function getOrder(req: Request, res: Response, next: NextFunction) {
  try {
    const id = Number(req.params.id);
    const data = await svc.getOrder(id);
    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function updateStatus(req: Request, res: Response, next: NextFunction) {
  try {
    const id = Number(req.params.id);
    const { status } = req.body;
    const data = await svc.updateStatus(id, { status });

    console.log('📦 Backend response data:', data);
    res.json(data);
  } catch (err) {
    next(err);
  }
}
