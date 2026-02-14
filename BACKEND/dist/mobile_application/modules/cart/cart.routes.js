"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.cartRouter = void 0;
const express_1 = require("express");
const cart_controller_1 = require("./cart.controller");
exports.cartRouter = (0, express_1.Router)();
// GET current cart
exports.cartRouter.get("/", cart_controller_1.getCart);
// Add item to cart
exports.cartRouter.post("/items", cart_controller_1.addItem);
// Update quantity (set absolute quantity; <=0 removes)
exports.cartRouter.patch("/items", cart_controller_1.updateItemQty);
// Remove item by menu item id
exports.cartRouter.delete("/items/:itemId", cart_controller_1.removeItem);
// Apply promo
exports.cartRouter.post("/apply-promo", cart_controller_1.applyPromo);
//# sourceMappingURL=cart.routes.js.map