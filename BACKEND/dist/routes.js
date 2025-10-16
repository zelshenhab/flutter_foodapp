"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_routes_1 = __importDefault(require("./modules/auth/auth.routes"));
const user_routes_1 = __importDefault(require("./modules/users/user.routes"));
const menu_routes_1 = __importDefault(require("./modules/menu/menu.routes"));
const promo_routes_1 = __importDefault(require("./modules/promos/promo.routes"));
const order_routes_1 = __importDefault(require("./modules/orders/order.routes"));
const support_routes_1 = __importDefault(require("./modules/support/support.routes"));
const router = (0, express_1.Router)();
router.use("/auth", auth_routes_1.default);
router.use("/users", user_routes_1.default);
router.use("/menu", menu_routes_1.default);
router.use("/promos", promo_routes_1.default);
router.use("/orders", order_routes_1.default);
router.use("/support", support_routes_1.default);
exports.default = router;
//# sourceMappingURL=routes.js.map