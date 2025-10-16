"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listCategories = listCategories;
exports.listItemsByCategory = listItemsByCategory;
exports.getItem = getItem;
const menu_service_1 = require("./menu.service");
async function listCategories(_req, res) {
    const data = await (0, menu_service_1.getCategories)();
    return res.json(data);
}
async function listItemsByCategory(req, res) {
    const { categoryId } = req.params;
    if (!categoryId)
        return res.status(400).json({ message: "categoryId is required" });
    const data = await (0, menu_service_1.getItemsByCategory)(categoryId);
    return res.json(data);
}
async function getItem(req, res) {
    const { itemId } = req.params;
    if (!itemId)
        return res.status(400).json({ message: "itemId is required" });
    const item = await (0, menu_service_1.getMenuItem)(itemId);
    if (!item)
        return res.status(404).json({ message: "Item not found" });
    return res.json(item);
}
//# sourceMappingURL=menu.controller.js.map