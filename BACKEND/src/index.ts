import dotenv from "dotenv";
dotenv.config();

import { createApp } from "./core/app";

const app = createApp();
const PORT = Number(process.env.PORT || 4000);

// Optional root message
app.get("/", (_req, res) => {
  res.send("FoodApp API is running. Try /health or /api/health");
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
