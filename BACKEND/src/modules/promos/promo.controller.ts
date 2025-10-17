import { Request, Response } from "express";
import * as svc from "./promo.service";

export async function listPromos(_req: Request, res: Response) {
  const data = await svc.fetchPromos();
  res.json({ data });
}
