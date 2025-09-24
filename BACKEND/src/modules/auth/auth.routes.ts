import { Router } from "express";
import { requestOtp, verifyOtp } from "./auth.controller";

export const authRouter = Router();
authRouter.post("/otp/request", requestOtp);
authRouter.post("/otp/verify", verifyOtp);
