"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.loyaltyRouter = void 0;
// backend/src/modules/loyalty/loyalty.routes.ts
const express_1 = require("express");
const loyalty_controller_1 = require("./loyalty.controller");
exports.loyaltyRouter = (0, express_1.Router)();
exports.loyaltyRouter.get("/info", loyalty_controller_1.getLoyaltyInfo);
exports.loyaltyRouter.post("/calculate", loyalty_controller_1.calculatePointsRedemption);
//# sourceMappingURL=loyalty.routes.js.map