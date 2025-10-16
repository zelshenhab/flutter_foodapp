import { Router } from "express";
import { postSupport } from "./support.controller";
import { optionalAuth } from "../../core/middlewares/auth.middleware";

const router = Router();

// Accept support with or without auth
router.post("/", optionalAuth as any, postSupport);

export default router;

