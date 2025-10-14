import { NextFunction, Request, Response } from "express";
import { JwtPayload, verifyAuthToken } from "../utils/jwt";

export interface AuthRequest extends Request {
  user?: JwtPayload;
}

export function requireAuth(req: AuthRequest, res: Response, next: NextFunction) {
  const header = req.headers["authorization"];
  if (!header || typeof header !== "string" || !header.toLowerCase().startsWith("bearer ")) {
    return res.status(401).json({ message: "Unauthorized" });
  }

  const token = header.slice(7).trim();
  try {
    const payload = verifyAuthToken(token);
    req.user = payload;
    next();
  } catch (err) {
    return res.status(401).json({ message: "Invalid or expired token" });
  }
}

