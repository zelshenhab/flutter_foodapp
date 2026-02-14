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
exports.previewOrder = previewOrder;
exports.createOrder = createOrder;
exports.listMyOrders = listMyOrders;
exports.getMyOrder = getMyOrder;
exports.completeOrder = completeOrder;
const svc = __importStar(require("./order.service"));
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
async function previewOrder(req, res) {
    const userId = userIdFrom(req);
    const data = await svc.preview(userId);
    res.json({ data });
}
async function createOrder(req, res) {
    const userId = userIdFrom(req);
    const { paymentMethod, address, notes } = req.body || {};
    if (!paymentMethod)
        throw { status: 400, message: "paymentMethod is required" };
    const data = await svc.createOrder(userId, { paymentMethod, address, notes });
    res.status(201).json(data);
}
async function listMyOrders(req, res) {
    const userId = userIdFrom(req);
    const { status, page, limit } = req.query;
    const data = await svc.listOrders(userId, {
        status,
        page: page ? Number(page) : undefined,
        limit: limit ? Number(limit) : undefined,
    });
    res.json(data);
}
async function getMyOrder(req, res) {
    const userId = userIdFrom(req);
    const id = Number(req.params.id);
    const data = await svc.getOrderDetail(userId, id);
    res.json({ data });
}
async function completeOrder(req, res) {
    const userId = userIdFrom(req);
    const id = Number(req.params.id);
    const data = await svc.completeOrder(userId, id);
    res.json({ data });
}
//# sourceMappingURL=order.controller.js.map