"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.createApp = createApp;
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const morgan_1 = __importDefault(require("morgan"));
// eslint-disable-next-line @typescript-eslint/no-var-requires
const listEndpoints = require("express-list-endpoints");
const routes_1 = require("../mobile_application/routes");
const routes_2 = require("../dashboard/routes");
const errorHandler_1 = require("./middlewares/errorHandler");
function createApp() {
    const app = (0, express_1.default)();
    // Enhanced CORS configuration
    app.use((0, cors_1.default)({
        origin: true, // Allow all origins in development
        credentials: true,
        methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
        allowedHeaders: ['Content-Type', 'Authorization', 'Accept']
    }));
    app.use((0, morgan_1.default)("dev"));
    app.use(express_1.default.json());
    app.get("/health", (_req, res) => res.json({ ok: true }));
    console.log("Router stack length before mount:", routes_1.router.stack?.length);
    app.use("/api", routes_1.router);
    app.use("/api/admin", routes_2.adminRouter);
    app.use(errorHandler_1.errorHandler);
    return app;
}
//# sourceMappingURL=app.js.map