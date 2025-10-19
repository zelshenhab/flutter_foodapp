import { Router } from "express";
import { addItem, applyPromo, getCart, removeItem } from "./cart.controller";

export const cartRouter = Router();

cartRouter.get("/", getCart);
cartRouter.post("/items", addItem);
cartRouter.delete("/items/:id", removeItem);
cartRouter.post("/apply-promo", applyPromo);
