import { Router } from "express";
import { postSendOtp, postVerifyOtp } from "./auth.controller";

const router = Router();

router.post("/send-otp", postSendOtp);
router.post("/verify-otp", postVerifyOtp);

export default router;

