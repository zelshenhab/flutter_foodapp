"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireAuth = requireAuth;
exports.optionalAuth = optionalAuth;
const jwt_1 = require("../utils/jwt");
function requireAuth(req, res, next) {
    const header = req.headers["authorization"];
    if (!header || typeof header !== "string" || !header.toLowerCase().startsWith("bearer ")) {
        return res.status(401).json({ message: "Unauthorized" });
    }
    const token = header.slice(7).trim();
    try {
        const payload = (0, jwt_1.verifyAuthToken)(token);
        req.user = payload;
        next();
    }
    catch (err) {
        return res.status(401).json({ message: "Invalid or expired token" });
    }
}
function optionalAuth(req, _res, next) {
    const header = req.headers["authorization"];
    if (header && typeof header === "string" && header.toLowerCase().startsWith("bearer ")) {
        const token = header.slice(7).trim();
        try {
            const payload = (0, jwt_1.verifyAuthToken)(token);
            req.user = payload;
        }
        catch {
            // ignore invalid token in optional mode
        }
    }
    next();
}
//# sourceMappingURL=auth.middleware.js.map