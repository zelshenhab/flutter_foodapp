import { Request, Response } from "express";

export async function createTicket(req: Request, res: Response) {
  res.json({ message: "Support ticket created" });
}
