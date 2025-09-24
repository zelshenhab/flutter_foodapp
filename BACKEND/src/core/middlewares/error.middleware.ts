import { Request, Response, NextFunction } from "express";

export function errorMiddleware(err: any, _req: Request, res: Response, _next: NextFunction) {
  console.error("[Error Middleware]", err);
  res.status(err.status || 500).json({ error: err.message || "Internal server error" });
}
