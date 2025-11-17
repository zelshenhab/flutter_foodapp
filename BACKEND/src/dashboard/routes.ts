import { Router } from "express";

// Orders
import * as orderController from "./controllers/admin.order.controller";
import * as menuController from "./controllers/admin.menu.controller";
import * as promoController from "./controllers/admin.promo.controller";
import * as analyticsController from "./controllers/admin.analytics.controller";
import { getSettingsHandler, updateSettingsHandler } from "./controllers/admin.settings.controller";
import { TicketsController } from "./controllers/tickets.controller";
import * as userController from "./controllers/users.controller"

export const adminRouter = Router();

/* ============================
      ⚠ IMPORTANT FIX:
   Put simple /:id routes LAST
==============================*/
// USERS
adminRouter.get("/users", userController.getUsers);
adminRouter.get("/users/:id", userController.getUser);
adminRouter.put("/users/:id/block", userController.blockUserController);
adminRouter.put("/users/:id/unblock", userController.unblockUserController);
adminRouter.put("/users/:id/role", userController.updateRoleController);


/* MENU */
adminRouter.get("/menu/categories", menuController.listCategories);
adminRouter.post("/menu/categories", menuController.createCategory);
adminRouter.patch("/menu/categories/:id", menuController.updateCategory);
adminRouter.delete("/menu/categories/:id", menuController.deleteCategory);

adminRouter.get("/menu/items", menuController.listItems);
adminRouter.post("/menu/items", menuController.createItem);
adminRouter.patch("/menu/items/:id", menuController.updateItem);
adminRouter.delete("/menu/items/:id", menuController.deleteItem);

/* ORDERS */
adminRouter.get("/orders", orderController.listOrders);
adminRouter.get("/orders/:id", orderController.getOrder);
adminRouter.patch("/orders/:id/status", orderController.updateStatus);

/* PROMOS */
adminRouter.get("/promos", promoController.listPromos);
adminRouter.post("/promos", promoController.createPromo);
adminRouter.patch("/promos/:id", promoController.updatePromo);
adminRouter.delete("/promos/:id", promoController.deletePromo);

/* ANALYTICS */
adminRouter.get("/analytics/daily-revenue", analyticsController.getDailyRevenue);
adminRouter.get("/analytics/orders-by-status", analyticsController.getOrdersByStatus);
adminRouter.get("/analytics/best-selling-items", analyticsController.getBestSellingItems);
adminRouter.get("/analytics/dashboard-stats", analyticsController.getDashboardStats);

/* SETTINGS */
adminRouter.get("/settings", getSettingsHandler);
adminRouter.put("/settings", updateSettingsHandler);

// TICKETS
adminRouter.get("/tickets", TicketsController.getAll);
adminRouter.post("/tickets/:id/respond", TicketsController.respond);
adminRouter.post("/tickets/:id/close", TicketsController.close);
adminRouter.post("/tickets/:id/reopen", TicketsController.reopen);

