import { Router } from "express";

export const router = Router();

// Example dashboard endpoints
router.get("/health", (_, res) => {
  res.json({ ok: true, source: "Dashboard API" });
});

// Here you’ll import real routes later:
// import { ordersRouter } from "./modules/orders/orders.routes";
// router.use("/orders", ordersRouter);
