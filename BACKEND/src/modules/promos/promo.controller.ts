import { Request, Response } from "express";
import { fetchActivePromos, findPromoByCode } from "./promo.service";
import { ValidatePromoRequest } from "./promo.types";

export async function getPromos(_req: Request, res: Response) {
  const promos = await fetchActivePromos();
  return res.json(promos);
}

export async function postValidatePromo(req: Request, res: Response) {
  const body = req.body as ValidatePromoRequest;
  if (!body?.code) return res.status(400).json({ message: "code is required" });
  const promo = await findPromoByCode(body.code);
  if (!promo) return res.status(404).json({ message: "Promo not found" });
  return res.json(promo);
}

