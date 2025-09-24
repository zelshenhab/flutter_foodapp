﻿import { createApp } from "./core/app";
import dotenv from "dotenv";

dotenv.config();
const app = createApp();
const PORT = process.env.PORT || 4000;

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
