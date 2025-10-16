import { Router } from "express";
import { requireAuth } from "../../core/middlewares/auth.middleware";
import { getOrder, getOrders, postOrder } from "./order.controller";

const router = Router();

router.get("/", requireAuth, getOrders);
router.get("/:orderId", requireAuth, getOrder);
router.post("/", requireAuth, postOrder);

export default router;

