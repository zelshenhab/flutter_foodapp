import { Request, Response } from "express";

export async function createTicket(_req: Request, res: Response) {
  res.json({ message: "Support ticket created" });
}
