import { Router } from "express";
import authRouter from "./modules/auth/auth.routes";
import userRouter from "./modules/users/user.routes";
import menuRouter from "./modules/menu/menu.routes";
import promoRouter from "./modules/promos/promo.routes";
import orderRouter from "./modules/orders/order.routes";
import supportRouter from "./modules/support/support.routes";

const router = Router();

router.use("/auth", authRouter);
router.use("/users", userRouter);
router.use("/menu", menuRouter);
router.use("/promos", promoRouter);
router.use("/orders", orderRouter);
router.use("/support", supportRouter);

export default router;

