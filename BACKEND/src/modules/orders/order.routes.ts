import { Router } from "express";
import { createOrder, previewOrder, getMyOrder, listMyOrders } from "./order.controller";

export const orderRouter = Router();

// New (Phase 4)
orderRouter.get("/", listMyOrders);     // GET /api/orders?status=pending&page=1&limit=10
orderRouter.get("/:id", getMyOrder);    // GET /api/orders/123

// Existing (Phase 3)
orderRouter.post("/preview", previewOrder);
orderRouter.post("/", createOrder);
