import jwt from "jsonwebtoken";

export interface JwtPayload {
  userId: string;
  phone: string;
}

const JWT_SECRET = (process.env.JWT_SECRET || "dev_secret");
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || "7d";

export function signAuthToken(payload: JwtPayload): string {
  return jwt.sign(payload, JWT_SECRET as jwt.Secret, { expiresIn: JWT_EXPIRES_IN } as any) as string;
}

export function verifyAuthToken(token: string): JwtPayload {
  return jwt.verify(token, JWT_SECRET as jwt.Secret) as JwtPayload;
}

