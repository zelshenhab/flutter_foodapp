import jwt from "jsonwebtoken";

const JWT_SECRET = process.env.JWT_SECRET || "changeme";
const ACCESS_TTL = "1h";
const REFRESH_TTL = "30d";

export function signAccess(payload: object) {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: ACCESS_TTL });
}
export function signRefresh(payload: object) {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: REFRESH_TTL });
}
export function verifyToken<T = any>(token: string): T {
  return jwt.verify(token, JWT_SECRET) as T;
}
