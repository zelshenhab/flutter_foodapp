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
exports.getLoyaltyInfo = getLoyaltyInfo;
exports.calculatePointsRedemption = calculatePointsRedemption;
exports.redeemPoints = redeemPoints;
const svc = __importStar(require("./loyalty.service"));
const jwt_1 = require("../../../core/utils/jwt");
function getUserId(req) {
    const auth = req.headers.authorization || "";
    const token = auth.startsWith("Bearer ") ? auth.slice(7) : "";
    if (!token)
        throw { status: 401, message: "Unauthorized" };
    const { valid, payload } = (0, jwt_1.verifyTokenSafe)(token);
    if (!valid)
        throw { status: 401, message: "Invalid token" };
    return payload.id;
}
async function getLoyaltyInfo(req, res) {
    try {
        const userId = getUserId(req);
        const data = await svc.getUserLoyalty(userId);
        res.json({ data });
    }
    catch (err) {
        res.status(err?.status || 500).json({
            message: err?.message || "Failed to fetch loyalty info"
        });
    }
}
async function calculatePointsRedemption(req, res) {
    try {
        const userId = getUserId(req);
        const { cartTotal, requestedPoints } = req.body;
        const data = await svc.calculatePointsRedemption(cartTotal, requestedPoints, userId);
        res.json({ data });
    }
    catch (err) {
        res.status(err?.status || 500).json({
            message: err?.message || "Failed to calculate points"
        });
    }
}
async function redeemPoints(req, res) {
    try {
        const userId = getUserId(req);
        const { points, orderId } = req.body;
        const data = await svc.redeemLoyaltyPoints(userId, points, orderId);
        res.json({ data });
    }
    catch (err) {
        res.status(err?.status || 500).json({
            message: err?.message || "Failed to redeem points"
        });
    }
}
//# sourceMappingURL=loyalty.controller.js.map