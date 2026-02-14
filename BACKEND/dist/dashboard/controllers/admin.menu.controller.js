"use strict";
// BACKEND/src/dashboard/controllers/admin.menu.controller.ts
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.listCategories = listCategories;
exports.createCategory = createCategory;
exports.updateCategory = updateCategory;
exports.deleteCategory = deleteCategory;
exports.listItems = listItems;
exports.createItem = createItem;
exports.updateItem = updateItem;
exports.deleteItem = deleteItem;
const svc = __importStar(require("../services/admin.menu.service"));
/* ========= CATEGORIES ========= */
async function listCategories(_req, res, next) {
    try {
        const data = await svc.listCategories();
        res.json({ data });
    }
    catch (err) {
        next(err);
    }
}
async function createCategory(req, res, next) {
    try {
        const data = await svc.createCategory(req.body);
        res.status(201).json({ data });
    }
    catch (err) {
        next(err);
    }
}
async function updateCategory(req, res, next) {
    try {
        const id = Number(req.params.id);
        const data = await svc.updateCategory(id, req.body);
        res.json({ data });
    }
    catch (err) {
        next(err);
    }
}
async function deleteCategory(req, res, next) {
    try {
        const id = Number(req.params.id);
        await svc.deleteCategory(id);
        res.json({ success: true });
    }
    catch (err) {
        next(err);
    }
}
/* ========= MENU ITEMS ========= */
async function listItems(req, res, next) {
    try {
        const { categoryId, search, isActive } = req.query;
        const data = await svc.listItems({
            categoryId: categoryId ? Number(categoryId) : undefined,
            search: search ? String(search) : undefined,
            isActive: typeof isActive === "string"
                ? isActive.toLowerCase() === "true"
                : undefined,
        });
        res.json({ data });
    }
    catch (err) {
        next(err);
    }
}
async function createItem(req, res, next) {
    try {
        const data = await svc.createItem(req.body);
        res.status(201).json({ data });
    }
    catch (err) {
        next(err);
    }
}
async function updateItem(req, res, next) {
    try {
        const id = Number(req.params.id);
        const data = await svc.updateItem(id, req.body);
        res.json({ data });
    }
    catch (err) {
        next(err);
    }
}
async function deleteItem(req, res, next) {
    try {
        const id = Number(req.params.id);
        await svc.deleteItem(id);
        res.json({ success: true });
    }
    catch (err) {
        next(err);
    }
}
//# sourceMappingURL=admin.menu.controller.js.map