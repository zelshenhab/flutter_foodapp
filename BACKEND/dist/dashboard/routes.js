"use strict";
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
exports.adminRouter = void 0;
const express_1 = require("express");
// Orders
const orderController = __importStar(require("./controllers/admin.order.controller"));
const menuController = __importStar(require("./controllers/admin.menu.controller"));
const promoController = __importStar(require("./controllers/admin.promo.controller"));
const analyticsController = __importStar(require("./controllers/admin.analytics.controller"));
const admin_settings_controller_1 = require("./controllers/admin.settings.controller");
const tickets_controller_1 = require("./controllers/tickets.controller");
const userController = __importStar(require("./controllers/users.controller"));
exports.adminRouter = (0, express_1.Router)();
/* ============================
      ⚠ IMPORTANT FIX:
   Put simple /:id routes LAST
==============================*/
// USERS
exports.adminRouter.use((req, res, next) => {
    console.log('🔐 ADMIN ROUTE ACCESSED:', {
        method: req.method,
        path: req.path,
        url: req.url,
        headers: req.headers,
        timestamp: new Date().toISOString()
    });
    next();
});
exports.adminRouter.get("/users", userController.getUsers);
exports.adminRouter.get("/users/:id", userController.getUser);
exports.adminRouter.put("/users/:id/block", userController.blockUserController);
exports.adminRouter.put("/users/:id/unblock", userController.unblockUserController);
exports.adminRouter.put("/users/:id/role", userController.updateRoleController);
/* MENU */
exports.adminRouter.get("/menu/categories", menuController.listCategories);
exports.adminRouter.post("/menu/categories", menuController.createCategory);
exports.adminRouter.patch("/menu/categories/:id", menuController.updateCategory);
exports.adminRouter.delete("/menu/categories/:id", menuController.deleteCategory);
exports.adminRouter.get("/menu/items", menuController.listItems);
exports.adminRouter.post("/menu/items", menuController.createItem);
exports.adminRouter.patch("/menu/items/:id", menuController.updateItem);
exports.adminRouter.delete("/menu/items/:id", menuController.deleteItem);
/* ORDERS */
exports.adminRouter.get("/orders", orderController.listOrders);
exports.adminRouter.get("/orders/:id", orderController.getOrder);
exports.adminRouter.put("/orders/:id/status", orderController.updateStatus);
/* PROMOS */
exports.adminRouter.get("/promos", promoController.listPromos);
exports.adminRouter.post("/promos", promoController.createPromo);
exports.adminRouter.patch("/promos/:id", promoController.updatePromo);
exports.adminRouter.delete("/promos/:id", promoController.deletePromo);
/* ANALYTICS */
exports.adminRouter.get("/analytics/daily-revenue", analyticsController.getDailyRevenue);
exports.adminRouter.get("/analytics/orders-by-status", analyticsController.getOrdersByStatus);
exports.adminRouter.get("/analytics/best-selling-items", analyticsController.getBestSellingItems);
exports.adminRouter.get("/analytics/dashboard-stats", analyticsController.getDashboardStats);
/* SETTINGS */
exports.adminRouter.get("/settings", admin_settings_controller_1.getSettingsHandler);
exports.adminRouter.put("/settings", admin_settings_controller_1.updateSettingsHandler);
// TICKETS
exports.adminRouter.get("/tickets", tickets_controller_1.TicketsController.getAll);
exports.adminRouter.post("/tickets/:id/respond", tickets_controller_1.TicketsController.respond);
exports.adminRouter.post("/tickets/:id/close", tickets_controller_1.TicketsController.close);
exports.adminRouter.post("/tickets/:id/reopen", tickets_controller_1.TicketsController.reopen);
//# sourceMappingURL=routes.js.map