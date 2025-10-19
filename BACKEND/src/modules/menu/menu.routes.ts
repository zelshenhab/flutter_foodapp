import { Router } from "express";
import { getCategories, getItems } from "./menu.controller";

export const menuRouter = Router();
menuRouter.get("/categories", getCategories);
menuRouter.get("/items", getItems);
