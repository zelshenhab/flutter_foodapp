"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getPromos = getPromos;
exports.postValidatePromo = postValidatePromo;
const promo_service_1 = require("./promo.service");
async function getPromos(_req, res) {
    const promos = await (0, promo_service_1.fetchActivePromos)();
    return res.json(promos);
}
async function postValidatePromo(req, res) {
    const body = req.body;
    if (!body?.code)
        return res.status(400).json({ message: "code is required" });
    const promo = await (0, promo_service_1.findPromoByCode)(body.code);
    if (!promo)
        return res.status(404).json({ message: "Promo not found" });
    return res.json(promo);
}
//# sourceMappingURL=promo.controller.js.map