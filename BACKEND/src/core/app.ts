﻿import express from "express";
import cors from "cors";
import { router } from "../routes";
import { errorMiddleware } from "./middlewares/error.middleware";

export function createApp() {
  const app = express();
  app.use(cors());
  app.use(express.json());
  app.use("/api", router);
  app.use(errorMiddleware);
  return app;
}
