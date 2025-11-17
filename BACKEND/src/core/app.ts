import express, { Express } from "express";
import cors from "cors";
import morgan from "morgan";
// eslint-disable-next-line @typescript-eslint/no-var-requires
const listEndpoints = require("express-list-endpoints") as (app: Express) => any[];
import { router } from "../mobile_application/routes";
import { adminRouter as adminRouter } from "../dashboard/routes";
import { errorHandler } from "./middlewares/errorHandler";

export function createApp(): Express {
  const app = express();

  // Enhanced CORS configuration
  app.use(cors({
    origin: true, // Allow all origins in development
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept']
  }));

  app.use(morgan("dev"));
  app.use(express.json());

  app.get("/health", (_req, res) => res.json({ ok: true }));

  console.log("Router stack length before mount:", (router as any).stack?.length);
  app.use("/api", router);         
  app.use("/api/admin", adminRouter);
  
  app.use(errorHandler);

  return app;
}