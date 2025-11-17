import { Request, Response, NextFunction } from "express";
import * as svc from "../services/admin.analytics.service";

function range(req: Request) {
  return {
    from: req.query.from ? String(req.query.from) : undefined,
    to: req.query.to ? String(req.query.to) : undefined,
  };
}

export async function getDailyRevenue(req: Request, res: Response, next: NextFunction) {
  try {
    const data = await svc.dailyRevenue(range(req));
    res.json({ data });
  } catch (err) {
    next(err);
  }
}

export async function getOrdersByStatus(req: Request, res: Response, next: NextFunction) {
  try {
    const data = await svc.ordersByStatus(range(req));
    res.json({ data });
  } catch (err) {
    next(err);
  }
}

export async function getBestSellingItems(req: Request, res: Response, next: NextFunction) {
  try {
    const data = await svc.bestSellingItems(range(req));
    res.json({ data });
  } catch (err) {
    next(err);
  }
}

export async function getDashboardStats(req: Request, res: Response, next: NextFunction) {
  try {
    const data = await svc.dashboardStats(range(req));
    res.json({ data });
  } catch (err) {
    next(err);
  }
}
