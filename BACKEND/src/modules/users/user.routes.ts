import { Router } from "express";
import { getProfile, updateProfile } from "./user.controller";

export const userRouter = Router();
userRouter.get("/me", getProfile);
userRouter.put("/me", updateProfile);
