// backend/src/modules/loyalty/loyalty.routes.ts
import { Router } from "express";
import { getLoyaltyInfo, calculatePointsRedemption, redeemPoints } from "./loyalty.controller";

export const loyaltyRouter = Router();

loyaltyRouter.get("/info", getLoyaltyInfo);
loyaltyRouter.post("/calculate", calculatePointsRedemption);
loyaltyRouter.post("/redeem", redeemPoints);