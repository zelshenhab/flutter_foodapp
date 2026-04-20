import { Router } from "express";
import { authRouter } from "./modules/auth/auth.routes";
import { cartRouter } from "./modules/cart/cart.routes";
import { menuRouter } from "./modules/menu/menu.routes";
import { orderRouter } from "./modules/orders/order.routes";
import { promoRouter } from "./modules/promos/promo.routes";
import { supportRouter } from "./modules/support/support.routes";
import { userRouter } from "./modules/users/user.routes";
import { paymentRouter } from "./modules/payment/payment.routes";
import { loyaltyRouter } from "./modules/loyalty/loyalty.routes";

export const router = Router();

router.use("/auth", authRouter);
router.use("/users", userRouter);
router.use("/menu", menuRouter);
router.use("/cart", cartRouter);
router.use("/orders", orderRouter);
router.use("/support", supportRouter);
router.use("/promos", promoRouter);
router.use("/loyalty", loyaltyRouter)

router.get("/health", (_, res) => res.json({ ok: true }));

router.use("/payment", paymentRouter);


// In your main router file, add:
router.get("/routes", (req, res) => {
  const routes: string[] = [];
  
  const extractRoutes = (stack: any[], basePath = "") => {
    stack.forEach((layer) => {
      if (layer.route) {
        const methods = Object.keys(layer.route.methods).join(", ").toUpperCase();
        routes.push(`${methods} ${basePath}${layer.route.path}`);
      } else if (layer.name === "router" && layer.handle.stack) {
        extractRoutes(layer.handle.stack, basePath);
      }
    });
  };
  
  extractRoutes((router as any).stack);
  res.json({ routes });
});
