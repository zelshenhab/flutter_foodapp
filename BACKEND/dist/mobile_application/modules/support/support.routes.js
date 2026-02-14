"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.supportRouter = void 0;
const express_1 = require("express");
const support_controller_1 = require("./support.controller");
exports.supportRouter = (0, express_1.Router)();
exports.supportRouter.post("/tickets", support_controller_1.createTicket);
//# sourceMappingURL=support.routes.js.map