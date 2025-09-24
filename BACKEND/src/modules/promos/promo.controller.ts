import { Request, Response } from "express";

export async function listPromos(req: Request, res: Response) {
  res.json([{ id: 1, code: "WELCOME10", discount: 10 }]);
}
