"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.router = void 0;
const express_1 = require("express");
const auth_routes_1 = require("./modules/auth/auth.routes");
const cart_routes_1 = require("./modules/cart/cart.routes");
const menu_routes_1 = require("./modules/menu/menu.routes");
const order_routes_1 = require("./modules/orders/order.routes");
const promo_routes_1 = require("./modules/promos/promo.routes");
const support_routes_1 = require("./modules/support/support.routes");
const user_routes_1 = require("./modules/users/user.routes");
const payment_routes_1 = require("./modules/payment/payment.routes");
const loyalty_routes_1 = require("./modules/loyalty/loyalty.routes");
exports.router = (0, express_1.Router)();
exports.router.use("/auth", auth_routes_1.authRouter);
exports.router.use("/users", user_routes_1.userRouter);
exports.router.use("/menu", menu_routes_1.menuRouter);
exports.router.use("/cart", cart_routes_1.cartRouter);
exports.router.use("/orders", order_routes_1.orderRouter);
exports.router.use("/support", support_routes_1.supportRouter);
exports.router.use("/promos", promo_routes_1.promoRouter);
exports.router.use("/loyalty", loyalty_routes_1.loyaltyRouter);
exports.router.get("/health", (_, res) => res.json({ ok: true }));
exports.router.use("/payment", payment_routes_1.paymentRouter);
// In your main router file, add:
exports.router.get("/routes", (req, res) => {
    const routes = [];
    const extractRoutes = (stack, basePath = "") => {
        stack.forEach((layer) => {
            if (layer.route) {
                const methods = Object.keys(layer.route.methods).join(", ").toUpperCase();
                routes.push(`${methods} ${basePath}${layer.route.path}`);
            }
            else if (layer.name === "router" && layer.handle.stack) {
                extractRoutes(layer.handle.stack, basePath);
            }
        });
    };
    extractRoutes(exports.router.stack);
    res.json({ routes });
});
//# sourceMappingURL=routes.js.map