import { Router } from "express";
import { createTicket } from "./support.controller";

export const supportRouter = Router();
supportRouter.post("/tickets", createTicket);
