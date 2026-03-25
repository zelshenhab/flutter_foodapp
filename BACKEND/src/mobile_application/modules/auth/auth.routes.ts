import { Router } from "express";
import { requestOtp, verifyOtp, getMe, postRefresh, logout, deleteAccount } from "./auth.controller";

export const authRouter = Router();

authRouter.post("/otp/request", requestOtp);
authRouter.post("/otp/verify", verifyOtp);
authRouter.post("/refresh", postRefresh);
authRouter.post("/logout", logout);
authRouter.delete("/delete-account", deleteAccount);
authRouter.get("/me", getMe);
