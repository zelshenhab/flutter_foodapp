"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listCategories = listCategories;
exports.listItemsByCategory = listItemsByCategory;
exports.getItem = getItem;
const menu_service_1 = require("./menu.service");
function listCategories(_req, res) {
    return res.json((0, menu_service_1.getCategories)());
}
function listItemsByCategory(req, res) {
    const { categoryId } = req.params;
    if (!categoryId)
        return res.status(400).json({ message: "categoryId is required" });
    return res.json((0, menu_service_1.getItemsByCategory)(categoryId));
}
function getItem(req, res) {
    const { itemId } = req.params;
    if (!itemId)
        return res.status(400).json({ message: "itemId is required" });
    const item = (0, menu_service_1.getMenuItem)(itemId);
    if (!item)
        return res.status(404).json({ message: "Item not found" });
    return res.json(item);
}
//# sourceMappingURL=menu.controller.js.map