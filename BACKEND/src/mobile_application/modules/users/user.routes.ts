import { Router } from "express";
import { getMe, updateMe } from "./user.controller";

export const userRouter = Router();

// Auth required on /me & avatar
userRouter.get("/me", getMe);
userRouter.put("/me", updateMe);
/*userRouter.put("/me/avatar", putAvatarUrl);

// Public profile by id (if you want it public; otherwise protect)
userRouter.get("/:id", getById);*/
