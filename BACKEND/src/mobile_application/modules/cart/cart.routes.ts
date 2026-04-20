import { Router } from "express";
import { addItem, getCart, applyPromo, updateItemQty, removeItem, applyLoyaltyPoints, removeLoyaltyPoints } from "./cart.controller";

export const cartRouter = Router();

// GET current cart
cartRouter.get("/", getCart);

// Add item to cart
cartRouter.post("/items", addItem);

// Update quantity (set absolute quantity; <=0 removes)
cartRouter.patch("/items", updateItemQty);

// Remove item by menu item id
cartRouter.delete("/items/:itemId", removeItem);

// Apply promo
cartRouter.post("/apply-promo", applyPromo);

cartRouter.post("/apply-points", applyLoyaltyPoints);
cartRouter.delete("/remove-points", removeLoyaltyPoints);