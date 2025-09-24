import { Router } from "express";
import { listPromos } from "./promo.controller";

export const promoRouter = Router();
promoRouter.get("/", listPromos);
