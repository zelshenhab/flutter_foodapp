import dotenv from "dotenv";
import { createApp } from "./core/app";

dotenv.config();

const app = createApp();

// Root route
app.get("/", (_req, res) => {
  res.send("FoodApp API is running. Try /health or /api/health");
});

// 🚀 IMPORTANT: export app instead of listen
export default app;
