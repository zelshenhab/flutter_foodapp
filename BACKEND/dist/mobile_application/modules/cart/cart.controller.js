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
exports.getCart = getCart;
exports.addItem = addItem;
exports.updateItemQty = updateItemQty;
exports.removeItem = removeItem;
exports.applyPromo = applyPromo;
exports.applyLoyaltyPoints = applyLoyaltyPoints;
exports.removeLoyaltyPoints = removeLoyaltyPoints;
const svc = __importStar(require("./cart.service"));
const jwt_1 = require("../../../core/utils/jwt");
function userIdFrom(req) {
    const auth = req.headers.authorization || "";
    const token = auth.startsWith("Bearer ") ? auth.slice(7) : "";
    if (!token)
        throw { status: 401, message: "Unauthorized" };
    const { valid, expired, payload } = (0, jwt_1.verifyTokenSafe)(token);
    if (!valid)
        throw { status: 401, message: expired ? "Token expired" : "Invalid token" };
    return payload.id;
}
async function getCart(req, res) {
    const userId = userIdFrom(req);
    const data = await svc.getCart(userId);
    res.json({ data });
}
async function addItem(req, res) {
    const userId = userIdFrom(req);
    const { itemId, quantity, optionIds } = req.body || {};
    if (!itemId)
        throw { status: 400, message: "itemId is required" };
    const id = await svc.addItem(userId, {
        itemId: Number(itemId),
        quantity: Number(quantity || 1),
        optionIds: optionIds || [],
    });
    res.status(201).json({ id });
}
async function updateItemQty(req, res) {
    const userId = userIdFrom(req);
    const { itemId, quantity } = req.body || {};
    if (!itemId || quantity === undefined)
        throw { status: 400, message: "itemId and quantity are required" };
    await svc.updateItemQuantity(userId, Number(itemId), Number(quantity));
    const data = await svc.getCart(userId);
    res.json({ data });
}
async function removeItem(req, res) {
    const userId = userIdFrom(req);
    const itemId = Number(req.params.itemId);
    if (!itemId)
        throw { status: 400, message: "Invalid itemId" };
    await svc.removeByMenuItem(userId, itemId);
    const data = await svc.getCart(userId);
    res.json({ data });
}
async function applyPromo(req, res) {
    const userId = userIdFrom(req);
    const { code } = req.body || {};
    const data = await svc.applyPromo(userId, String(code || ""));
    res.json({ data });
}
async function applyLoyaltyPoints(req, res) {
    try {
        const userId = userIdFrom(req);
        const { points } = req.body;
        if (!points || points < 100) {
            return res.status(400).json({ message: "Minimum 100 points required" });
        }
        const data = await svc.applyLoyaltyPoints(userId, points);
        res.json({ data });
    }
    catch (err) {
        res.status(err?.status || 500).json({
            message: err?.message || "Failed to apply loyalty points"
        });
    }
}
async function removeLoyaltyPoints(req, res) {
    try {
        const userId = userIdFrom(req);
        const data = await svc.removeLoyaltyPoints(userId);
        res.json({ data });
    }
    catch (err) {
        res.status(err?.status || 500).json({
            message: err?.message || "Failed to remove loyalty points"
        });
    }
}
//# sourceMappingURL=cart.controller.js.map