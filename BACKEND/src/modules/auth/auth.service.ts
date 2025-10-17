import { prisma } from "../../core/config/db";
import { randomBytes } from "crypto";
import { addMinutes, isBefore } from "date-fns";
import { signAccess, signRefresh } from "../../core/utils/jwt";
import type { JwtUser } from "./auth.types";

const OTP_TTL_MIN = 2;
const MAX_ATTEMPTS = 5;
const DEV_CODE = "111111"; // use real SMS in prod

export async function requestOtp(phone: string) {
  const requestId = randomBytes(12).toString("hex");
  const code = process.env.NODE_ENV === "production"
    ? (Math.floor(100000 + Math.random() * 900000)).toString()
    : DEV_CODE;

  await prisma.otpRequest.create({
    data: {
      phone,
      code,
      requestId,
      expiresAt: addMinutes(new Date(), OTP_TTL_MIN),
    },
  });

  // TODO: send SMS in prod
  return { requestId, ttl: OTP_TTL_MIN * 60, devCode: code === DEV_CODE ? DEV_CODE : undefined };
}

export async function verifyOtp(phone: string, requestId: string, code: string) {
  const rec = await prisma.otpRequest.findUnique({ where: { requestId } });
  if (!rec || rec.phone !== phone) throw { status: 400, message: "Invalid request" };
  if (rec.attempts >= MAX_ATTEMPTS) throw { status: 429, message: "Too many attempts" };
  if (isBefore(rec.expiresAt, new Date())) throw { status: 400, message: "Code expired" };

  // increment attempts
  await prisma.otpRequest.update({
    where: { id: rec.id },
    data: { attempts: rec.attempts + 1 },
  });

  if (rec.code !== code) throw { status: 400, message: "Invalid code" };

  // upsert user
  const user = await prisma.user.upsert({
    where: { phone },
    update: {},
    create: { phone },
  });

  const payload: JwtUser = { id: user.id, phone: user.phone };
  const accessToken = signAccess(payload);
  const refreshToken = signRefresh(payload);

  await prisma.refreshToken.create({
    data: {
      userId: user.id,
      token: refreshToken,
      expiresAt: new Date(Date.now() + 30 * 24 * 3600 * 1000), // 30d
    },
  });

  return { accessToken, refreshToken, user };
}

export async function me(userId: number) {
  return prisma.user.findUnique({ where: { id: userId } });
}

export async function refresh(oldToken: string) {
  const rec = await prisma.refreshToken.findUnique({ where: { token: oldToken } });
  if (!rec || rec.revoked) throw { status: 401, message: "Invalid refresh token" };
  if (isBefore(rec.expiresAt, new Date())) throw { status: 401, message: "Refresh expired" };

  const user = await prisma.user.findUnique({ where: { id: rec.userId } });
  if (!user) throw { status: 401, message: "User not found" };

  const payload: JwtUser = { id: user.id, phone: user.phone };
  const accessToken = signAccess(payload);
  return { accessToken };
}
