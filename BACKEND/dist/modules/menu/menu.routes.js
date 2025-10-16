"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const menu_controller_1 = require("./menu.controller");
const router = (0, express_1.Router)();
router.get("/categories", menu_controller_1.listCategories);
router.get("/categories/:categoryId/items", menu_controller_1.listItemsByCategory);
router.get("/items/:itemId", menu_controller_1.getItem);
exports.default = router;
//# sourceMappingURL=menu.routes.js.map