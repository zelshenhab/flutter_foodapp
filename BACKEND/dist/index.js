"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const dotenv_1 = __importDefault(require("dotenv"));
const app_1 = require("./core/app");
dotenv_1.default.config();
const app = (0, app_1.createApp)();
// Root route
app.get("/", (_req, res) => {
    res.send("FoodApp API is running. Try /health or /api/health");
});
// 🚀 IMPORTANT: export app instead of listen
exports.default = app;
//# sourceMappingURL=index.js.map