import { Router } from "express";
import { getPromos, postValidatePromo } from "./promo.controller";

const router = Router();

router.get("/", getPromos);
router.post("/validate", postValidatePromo);

export default router;

