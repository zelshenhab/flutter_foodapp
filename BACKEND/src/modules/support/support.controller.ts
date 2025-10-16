import { Response } from "express";
import { AuthRequest } from "../../core/middlewares/auth.middleware";
import { submitSupportMessage } from "./support.service";
import { SubmitSupportRequest } from "./support.types";

export function postSupport(req: AuthRequest, res: Response) {
  const body = req.body as SubmitSupportRequest;
  if (!body?.subject || !body?.message) {
    return res.status(400).json({ message: "subject and message are required" });
  }
  const userId = req.user?.userId;
  const created = submitSupportMessage({ userId, phone: body.phone, subject: body.subject, message: body.message });
  return res.status(201).json(created);
}

