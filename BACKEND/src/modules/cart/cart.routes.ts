import { Router } from "express";
import { getCart, addItem } from "./cart.controller";

export const cartRouter = Router();
cartRouter.get("/", getCart);
cartRouter.post("/items", addItem);
