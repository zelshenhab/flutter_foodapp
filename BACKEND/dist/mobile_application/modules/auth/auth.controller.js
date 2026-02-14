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
exports.requestOtp = requestOtp;
exports.verifyOtp = verifyOtp;
exports.getMe = getMe;
exports.postRefresh = postRefresh;
const svc = __importStar(require("./auth.service"));
const jwt_1 = require("../../../core/utils/jwt");
async function requestOtp(req, res) {
    try {
        const { email } = req.body || {};
        if (!email) {
            return res.status(400).json({ message: "email is required" });
        }
        const data = await svc.requestOtp(email);
        return res.status(200).json(data);
    }
    catch (err) {
        console.error("❌ requestOtp error:", err);
        return res.status(err?.status || 500).json({
            message: err?.message || "Internal server error",
        });
    }
}
async function verifyOtp(req, res) {
    try {
        const { email, requestId, code } = req.body || {};
        if (!email || !requestId || !code) {
            return res
                .status(400)
                .json({ message: "email, requestId, code are required" });
        }
        const data = await svc.verifyOtp(email, requestId, code);
        return res.status(200).json(data);
    }
    catch (err) {
        console.error("❌ verifyOtp error:", err);
        return res.status(err?.status || 500).json({
            message: err?.message || "Internal server error",
        });
    }
}
async function getMe(req, res) {
    try {
        const header = req.headers.authorization || "";
        const token = header.startsWith("Bearer ") ? header.slice(7) : null;
        if (!token) {
            return res.status(401).json({ message: "Unauthorized" });
        }
        const { valid, expired, payload } = (0, jwt_1.verifyTokenSafe)(token);
        if (!valid) {
            return res.status(401).json({
                message: expired ? "Token expired" : "Invalid token",
            });
        }
        const user = await svc.me(payload.id);
        return res.status(200).json({ user });
    }
    catch (err) {
        console.error("❌ getMe error:", err);
        return res.status(err?.status || 500).json({
            message: err?.message || "Internal server error",
        });
    }
}
async function postRefresh(req, res) {
    try {
        const { refreshToken } = req.body || {};
        if (!refreshToken) {
            return res
                .status(400)
                .json({ message: "refreshToken is required" });
        }
        const data = await svc.refresh(refreshToken);
        return res.status(200).json(data);
    }
    catch (err) {
        console.error("❌ refresh error:", err);
        return res.status(err?.status || 500).json({
            message: err?.message || "Internal server error",
        });
    }
}
//# sourceMappingURL=auth.controller.js.map