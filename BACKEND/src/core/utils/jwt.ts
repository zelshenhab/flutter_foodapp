import jwt, { TokenExpiredError, JsonWebTokenError } from "jsonwebtoken";

const JWT_SECRET = process.env.JWT_SECRET || "changeme";
const ACCESS_TTL = "1h";   // 1 hour
const REFRESH_TTL = "30d"; // 30 days

/**
 * Signs a short-lived access token
 */
export function signAccess(payload: object): string {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: ACCESS_TTL });
}

/**
 * Signs a long-lived refresh token
 */
export function signRefresh(payload: object): string {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: REFRESH_TTL });
}

/**
 * Verifies a token safely — never throws.
 * Returns an object describing validity and expiration.
 */
export function verifyTokenSafe<T = any>(
  token: string
): { valid: boolean; expired?: boolean; payload?: T } {
  try {
    const payload = jwt.verify(token, JWT_SECRET) as T;
    return { valid: true, payload };
  } catch (error) {
    if (error instanceof TokenExpiredError) {
      console.warn("⚠️ Token expired at:", error.expiredAt);
      return { valid: false, expired: true };
    }
    if (error instanceof JsonWebTokenError) {
      console.warn("⚠️ Invalid token:", error.message);
      return { valid: false };
    }
    console.error("Unexpected JWT error:", error);
    return { valid: false };
  }
}

/**
 * Strict verify (original behavior). Throws if invalid/expired.
 * You can keep this for internal trusted calls if needed.
 */
export function verifyToken<T = any>(token: string): T {
  return jwt.verify(token, JWT_SECRET) as T;
}
