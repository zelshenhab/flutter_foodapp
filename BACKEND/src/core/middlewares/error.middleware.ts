import { NextFunction, Request, Response } from "express";

export function notFoundHandler(req: Request, res: Response) {
  res.status(404).json({ message: "Not Found" });
}

export function errorHandler(err: unknown, req: Request, res: Response, _next: NextFunction) {
  const isDev = process.env.NODE_ENV !== "production";
  const message = err instanceof Error ? err.message : "Internal Server Error";
  const stack = err instanceof Error ? err.stack : undefined;
  res.status(500).json({ message, ...(isDev && stack ? { stack } : {}) });
}

