"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.notFoundHandler = notFoundHandler;
exports.errorHandler = errorHandler;
function notFoundHandler(req, res) {
    res.status(404).json({ message: "Not Found" });
}
function errorHandler(err, req, res, _next) {
    const isDev = process.env.NODE_ENV !== "production";
    const message = err instanceof Error ? err.message : "Internal Server Error";
    const stack = err instanceof Error ? err.stack : undefined;
    res.status(500).json({ message, ...(isDev && stack ? { stack } : {}) });
}
//# sourceMappingURL=error.middleware.js.map