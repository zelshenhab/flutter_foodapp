"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.promoRouter = void 0;
const express_1 = require("express");
const promo_controller_1 = require("./promo.controller");
exports.promoRouter = (0, express_1.Router)();
exports.promoRouter.get("/", promo_controller_1.listPromos);
//# sourceMappingURL=promo.routes.js.map