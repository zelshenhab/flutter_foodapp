import { Router } from "express";
import { requestOtp, verifyOtp, getMe, postRefresh } from "./auth.controller";

export const authRouter = Router();

authRouter.post("/otp/request", requestOtp);
authRouter.post("/otp/verify", verifyOtp);
authRouter.post("/refresh", postRefresh);
authRouter.get("/me", getMe);
