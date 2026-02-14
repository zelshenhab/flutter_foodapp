"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TicketsController = void 0;
const tickets_service_1 = require("../services/tickets.service");
const service = new tickets_service_1.TicketsService();
class TicketsController {
    static getAll(req, res) {
        return res.json({ data: service.getAll() });
    }
    static respond(req, res) {
        const { id } = req.params;
        const { message } = req.body;
        const result = service.respond(id, message);
        if (!result)
            return res.status(404).json({ error: "Ticket not found" });
        return res.json(result);
    }
    static close(req, res) {
        const { id } = req.params;
        const result = service.close(id);
        if (!result)
            return res.status(404).json({ error: "Ticket not found" });
        return res.json(result);
    }
    static reopen(req, res) {
        const { id } = req.params;
        const result = service.reopen(id);
        if (!result)
            return res.status(404).json({ error: "Ticket not found" });
        return res.json(result);
    }
}
exports.TicketsController = TicketsController;
//# sourceMappingURL=tickets.controller.js.map