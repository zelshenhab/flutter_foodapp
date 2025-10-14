import { Request, Response } from "express";
import { sendOtp, verifyOtp } from "./auth.service";
import { SendOtpRequest, VerifyOtpRequest } from "./auth.types";

export function postSendOtp(req: Request, res: Response) {
  const body = req.body as SendOtpRequest;
  if (!body?.phone) return res.status(400).json({ message: "phone is required" });
  const ok = sendOtp(body.phone);
  return res.json({ success: ok });
}

export function postVerifyOtp(req: Request, res: Response) {
  const body = req.body as VerifyOtpRequest;
  if (!body?.phone || !body?.code) {
    return res.status(400).json({ message: "phone and code are required" });
  }
  const result = verifyOtp(body.phone, body.code);
  if (!result) return res.status(401).json({ message: "Invalid code" });
  return res.json(result);
}

