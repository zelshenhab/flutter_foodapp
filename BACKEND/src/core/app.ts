import express, { Express } from "express";
import cors from "cors";
import morgan from "morgan";
// eslint-disable-next-line @typescript-eslint/no-var-requires
const listEndpoints = require("express-list-endpoints") as (app: Express) => any[];
import { router } from "../routes";

export function createApp(): Express {
  const app = express();

  app.use(cors());
  app.use(morgan("dev"));
  app.use(express.json());

  app.get("/health", (_req, res) => res.json({ ok: true }));

  console.log("Router stack length before mount:", (router as any).stack?.length);
  app.use("/api", router);

  // Debug helper for Express 4/5, routers, and nested mounts
function collectRoutes(app: any) {
  const out: Array<{ method: string; path: string }> = [];

  const walk = (stack: any[], prefix = "") => {
    for (const layer of stack) {
      // Mounted router (e.g., /api, /menu, etc.)
      if (layer.name === "router" && layer.handle?.stack) {
        // Try to reconstruct the mount path from the regexp (best-effort)
        let mount = "";
        if (layer.regexp && layer.regexp.fast_star) mount = "*";
        else if (layer.regexp && layer.regexp.fast_slash) mount = "/";
        else if (layer.regexp) {
          const m = layer.regexp
            .toString()
            .match(/^\/\\\/\^\\(.*)\\\/\?\(\?=\\\/\|\$\)\\\/i?$/); // fragile but works often
          if (m && m[1]) mount = m[1].replace(/\\\//g, "/");
        }
        walk(layer.handle.stack, prefix + "/" + mount);
      }

      // Direct route on this stack
      if (layer.route) {
        const routePath = prefix + layer.route.path;
        const methods = Object.keys(layer.route.methods);
        for (const m of methods) {
          out.push({ method: m.toUpperCase(), path: routePath.replace(/\/+/g, "/") });
        }
      }
    }
  };

  if (app._router?.stack) walk(app._router.stack);
  return out;
}

// AFTER app.use("/api", router);
console.log("==== Registered endpoints (custom) ====");
console.log(collectRoutes(app));
console.log("=======================================");

  return app;
}
