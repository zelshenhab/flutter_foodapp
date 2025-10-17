import { createApp } from "./core/app";
import dotenv from "dotenv";
import express from "express"; // at top if not already

dotenv.config();
const app = createApp();
const PORT = process.env.PORT || 4000;

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});

(app as express.Express).get("/", (_req, res) => {
  res.send("FoodApp API is running. Try /api/health");
});