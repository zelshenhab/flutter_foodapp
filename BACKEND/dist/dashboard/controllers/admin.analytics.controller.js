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
exports.getDailyRevenue = getDailyRevenue;
exports.getOrdersByStatus = getOrdersByStatus;
exports.getBestSellingItems = getBestSellingItems;
exports.getDashboardStats = getDashboardStats;
const svc = __importStar(require("../services/admin.analytics.service"));
function range(req) {
    return {
        from: req.query.from ? String(req.query.from) : undefined,
        to: req.query.to ? String(req.query.to) : undefined,
    };
}
async function getDailyRevenue(req, res, next) {
    try {
        const data = await svc.dailyRevenue(range(req));
        res.json({ data });
    }
    catch (err) {
        next(err);
    }
}
async function getOrdersByStatus(req, res, next) {
    try {
        const data = await svc.ordersByStatus(range(req));
        res.json({ data });
    }
    catch (err) {
        next(err);
    }
}
async function getBestSellingItems(req, res, next) {
    try {
        const data = await svc.bestSellingItems(range(req));
        res.json({ data });
    }
    catch (err) {
        next(err);
    }
}
async function getDashboardStats(req, res, next) {
    try {
        const data = await svc.dashboardStats(range(req));
        res.json({ data });
    }
    catch (err) {
        next(err);
    }
}
//# sourceMappingURL=admin.analytics.controller.js.map