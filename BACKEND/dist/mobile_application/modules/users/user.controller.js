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
exports.getMe = getMe;
exports.updateMe = updateMe;
const jwt_1 = require("../../../core/utils/jwt");
const svc = __importStar(require("./user.service"));
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
async function getMe(req, res) {
    const userId = userIdFrom(req);
    const me = await svc.getMe(userId);
    res.json(me);
}
async function updateMe(req, res) {
    const userId = userIdFrom(req);
    const { name, avatarUrl } = req.body || {};
    const patch = {};
    if (typeof name === "string")
        patch.name = name;
    if (typeof avatarUrl === "string" || avatarUrl === null)
        patch.avatarUrl = avatarUrl;
    const updated = await svc.updateMe(userId, patch);
    res.json(updated);
}
//# sourceMappingURL=user.controller.js.map