import { Request, Response } from "express";

export async function requestOtp(req: Request, res: Response) {
  res.json({ message: "OTP request endpoint" });
}
export async function verifyOtp(req: Request, res: Response) {
  res.json({ message: "OTP verify endpoint" });
}
