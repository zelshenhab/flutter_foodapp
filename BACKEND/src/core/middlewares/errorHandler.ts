import { Request, Response, NextFunction } from "express";

export function errorHandler(err: any, req: Request, res: Response, _next: NextFunction) {
  const status = err.status || 500;
  const message = err.message || "Internal server error";

  // Don't convert JSON parsing errors to token errors
  const isJsonParseError = err.type === 'entity.parse.failed' || 
                          err.name === 'SyntaxError' && 
                          message.includes('JSON');
  
  if (!isJsonParseError && message.toLowerCase().includes("token")) {
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

  // Handle JSON parsing errors properly
  if (isJsonParseError) {
    return res.status(400).json({
      success: false,
      error: "Invalid JSON in request body",
    });
  }

  // Handle common cases
  if (status === 400) {
    return res.status(400).json({ success: false, error: message });
  }

  if (status === 401) {
    return res.status(401).json({ success: false, error: message || "Unauthorized" });
  }

  console.error("❌ Unhandled error:", err);
  return res.status(status).json({
    success: false,
    error: message,
  });
}