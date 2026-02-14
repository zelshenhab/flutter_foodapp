"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireAuth = requireAuth;
function requireAuth(req, res, next) {
    // TODO: implement JWT validation
    return res.status(401).json({ error: "Unauthorized" });
}
//# sourceMappingURL=auth.middleware.js.map