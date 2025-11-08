import { Request, Response } from "express";
import * as svc from "./auth.service";
import { verifyTokenSafe } from "../../../core/utils/jwt";

export async function requestOtp(req: Request, res: Response) {
  const { phone } = req.body || {};
  if (!phone) throw { status: 400, message: "phone is required" };

  const data = await svc.requestOtp(phone);
  res.json(data);
}

export async function verifyOtp(req: Request, res: Response) {
  const { phone, requestId, code } = req.body || {};
  if (!phone || !requestId || !code)
    throw { status: 400, message: "phone, requestId, code are required" };

  const data = await svc.verifyOtp(phone, requestId, code);
  res.json(data);
}

export async function getMe(req: Request, res: Response) {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;
  if (!token) throw { status: 401, message: "Unauthorized" };

  const { valid, expired, payload } = verifyTokenSafe<{ id: number }>(token);
  if (!valid)
    throw { status: 401, message: expired ? "Token expired" : "Invalid token" };

  const user = await svc.me(payload!.id);
  res.json({ user });
}

export async function postRefresh(req: Request, res: Response) {
  const { refreshToken } = req.body || {};
  if (!refreshToken) throw { status: 400, message: "refreshToken is required" };

  const data = await svc.refresh(refreshToken);
  res.json(data);
}
