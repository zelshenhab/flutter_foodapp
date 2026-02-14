"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.menuRouter = void 0;
const express_1 = require("express");
const menu_controller_1 = require("./menu.controller");
exports.menuRouter = (0, express_1.Router)();
exports.menuRouter.get("/categories", menu_controller_1.getCategories);
exports.menuRouter.get("/items", menu_controller_1.getItems);
//# sourceMappingURL=menu.routes.js.map