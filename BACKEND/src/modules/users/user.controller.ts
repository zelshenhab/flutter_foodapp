import { Response } from "express";
import { AuthRequest } from "../../core/middlewares/auth.middleware";
import { getUserProfile, updateUserProfile } from "./user.service";
import { UpdateUserProfileRequest } from "./user.types";

export async function getMe(req: AuthRequest, res: Response) {
  const userId = req.user!.userId;
  const profile = await getUserProfile(userId);
  if (!profile) return res.status(404).json({ message: "User not found" });
  return res.json(profile);
}

export async function patchMe(req: AuthRequest, res: Response) {
  const userId = req.user!.userId;
  const body = req.body as UpdateUserProfileRequest;
  const updated = await updateUserProfile(userId, body);
  if (!updated) return res.status(404).json({ message: "User not found" });
  return res.json(updated);
}

