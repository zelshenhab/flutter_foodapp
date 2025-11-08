import { Request, Response, NextFunction } from "express";

export function errorHandler(err: any, _req: Request, res: Response, _next: NextFunction) {
  // Default values
  const status = err.status || 500;
  const message = err.message || "Internal server error";

  // Handle JWT-specific cases
  if (message.toLowerCase().includes("token")) {
    if (message.toLowerCase().includes("expired")) {
      return res.status(401).json({
        success: false,
        error: "Your session has expired. Please log in again.",
      });
    }
    return res.status(401).json({
      success: false,
      error: "Invalid or missing token.",
    });
  }

  // Handle common cases
  if (status === 400) {
    return res.status(400).json({ success: false, error: message });
  }

  if (status === 401) {
    return res.status(401).json({ success: false, error: message || "Unauthorized" });
  }

  // Default catch-all
  console.error("❌ Unhandled error:", err);
  return res.status(status).json({
    success: false,
    error: message,
  });
}
