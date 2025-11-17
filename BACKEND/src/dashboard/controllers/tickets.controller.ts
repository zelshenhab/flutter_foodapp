import { Request, Response } from "express";
import { TicketsService } from "../services/tickets.service";

const service = new TicketsService();

export class TicketsController {
  static getAll(req: Request, res: Response) {
    return res.json({ data: service.getAll() });
  }

  static respond(req: Request, res: Response) {
    const { id } = req.params;
    const { message } = req.body;

    const result = service.respond(id, message);
    if (!result) return res.status(404).json({ error: "Ticket not found" });

    return res.json(result);
  }

  static close(req: Request, res: Response) {
    const { id } = req.params;

    const result = service.close(id);
    if (!result) return res.status(404).json({ error: "Ticket not found" });

    return res.json(result);
  }

  static reopen(req: Request, res: Response) {
    const { id } = req.params;

    const result = service.reopen(id);
    if (!result) return res.status(404).json({ error: "Ticket not found" });

    return res.json(result);
  }
}
