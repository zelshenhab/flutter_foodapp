import { Router } from "express";
import { getItem, listCategories, listItemsByCategory } from "./menu.controller";

const router = Router();

router.get("/categories", listCategories);
router.get("/categories/:categoryId/items", listItemsByCategory);
router.get("/items/:itemId", getItem);

export default router;

