"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const promo_controller_1 = require("./promo.controller");
const router = (0, express_1.Router)();
router.get("/", promo_controller_1.getPromos);
router.post("/validate", promo_controller_1.postValidatePromo);
exports.default = router;
//# sourceMappingURL=promo.routes.js.map