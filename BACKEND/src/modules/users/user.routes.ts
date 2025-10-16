import { Router } from "express";
import { requireAuth } from "../../core/middlewares/auth.middleware";
import { getMe, patchMe } from "./user.controller";

const router = Router();

router.get("/me", requireAuth, getMe);
router.patch("/me", requireAuth, patchMe);

export default router;

