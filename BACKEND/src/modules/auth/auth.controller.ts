import { Request, Response } from "express";
import * as svc from "./auth.service";
import { verifyToken } from "../../core/utils/jwt";

export async function requestOtp(req: Request, res: Response) {
  const { phone } = req.body || {};
  if (!phone) return res.status(400).json({ error: "phone is required" });
  const data = await svc.requestOtp(phone);
  res.json(data);
}

export async function verifyOtp(req: Request, res: Response) {
  const { phone, requestId, code } = req.body || {};
  if (!phone || !requestId || !code) {
    return res.status(400).json({ error: "phone, requestId, code are required" });
  }
  const data = await svc.verifyOtp(phone, requestId, code);
  res.json(data);
}

export async function getMe(req: Request, res: Response) {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: "Unauthorized" });
  const payload = verifyToken<{ id: number }>(token);
  const user = await svc.me(payload.id);
  res.json({ user });
}

export async function postRefresh(req: Request, res: Response) {
  const { refreshToken } = req.body || {};
  if (!refreshToken) return res.status(400).json({ error: "refreshToken is required" });
  const data = await svc.refresh(refreshToken);
  res.json(data);
}
