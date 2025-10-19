import { Request, Response, NextFunction } from "express";

export function requireAuth(req: Request, res: Response, next: NextFunction) {
  // TODO: implement JWT validation
  return res.status(401).json({ error: "Unauthorized" });
}
