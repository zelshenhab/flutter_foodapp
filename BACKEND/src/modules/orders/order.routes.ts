import { Router } from "express";
import { listOrders, getOrder } from "./order.controller";

export const orderRouter = Router();
orderRouter.get("/", listOrders);
orderRouter.get("/:id", getOrder);
