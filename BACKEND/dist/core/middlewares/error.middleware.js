"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorMiddleware = errorMiddleware;
function errorMiddleware(err, _req, res, _next) {
    console.error("[Error Middleware]", err);
    res.status(err.status || 500).json({ error: err.message || "Internal server error" });
}
//# sourceMappingURL=error.middleware.js.map