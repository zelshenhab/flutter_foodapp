import { Router } from "express";
import { authRouter } from "./modules/auth/auth.routes";
import { cartRouter } from "./modules/cart/cart.routes";
import { menuRouter } from "./modules/menu/menu.routes";
import { orderRouter } from "./modules/orders/order.routes";
import { promoRouter } from "./modules/promos/promo.routes";
import { supportRouter } from "./modules/support/support.routes";
import { userRouter } from "./modules/users/user.routes";

export const router = Router();

router.use("/auth", authRouter);
router.use("/users", userRouter);
router.use("/menu", menuRouter);
router.use("/cart", cartRouter);
router.use("/orders", orderRouter);
router.use("/support", supportRouter);
router.use("/promos", promoRouter);

router.get("/health", (_, res) => res.json({ ok: true }));
