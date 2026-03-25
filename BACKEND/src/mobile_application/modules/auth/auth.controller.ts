import { Request, Response } from "express";
import * as svc from "./auth.service";
import { verifyTokenSafe } from "../../../core/utils/jwt";

export async function requestOtp(req: Request, res: Response) {
  try {
    const { email } = req.body || {};

    if (!email) {
      return res.status(400).json({ message: "email is required" });
    }

    const data = await svc.requestOtp(email);
    return res.status(200).json(data);

  } catch (err: any) {
    console.error("❌ requestOtp error:", err);

    return res.status(err?.status || 500).json({
      message: err?.message || "Internal server error",
    });
  }
}

export async function verifyOtp(req: Request, res: Response) {
  try {
    const { email, requestId, code } = req.body || {};

    if (!email || !requestId || !code) {
      return res
        .status(400)
        .json({ message: "email, requestId, code are required" });
    }

    const data = await svc.verifyOtp(email, requestId, code);
    return res.status(200).json(data);

  } catch (err: any) {
    console.error("❌ verifyOtp error:", err);

    return res.status(err?.status || 500).json({
      message: err?.message || "Internal server error",
    });
  }
}

export async function getMe(req: Request, res: Response) {
  try {
    const header = req.headers.authorization || "";
    const token = header.startsWith("Bearer ") ? header.slice(7) : null;

    if (!token) {
      return res.status(401).json({ message: "Unauthorized" });
    }

    const { valid, expired, payload } =
      verifyTokenSafe<{ id: number }>(token);

    if (!valid) {
      return res.status(401).json({
        message: expired ? "Token expired" : "Invalid token",
      });
    }

    const user = await svc.me(payload!.id);
    return res.status(200).json({ user });

  } catch (err: any) {
    console.error("❌ getMe error:", err);

    return res.status(err?.status || 500).json({
      message: err?.message || "Internal server error",
    });
  }
}

export async function postRefresh(req: Request, res: Response) {
  try {
    const { refreshToken } = req.body || {};

    if (!refreshToken) {
      return res
        .status(400)
        .json({ message: "refreshToken is required" });
    }

    const data = await svc.refresh(refreshToken);
    return res.status(200).json(data);

  } catch (err: any) {
    console.error("❌ refresh error:", err);

    return res.status(err?.status || 500).json({
      message: err?.message || "Internal server error",
    });
  }
}

export async function logout(req: Request, res: Response) {
  try {
    const { refreshToken } = req.body || {};

    if (!refreshToken) {
      return res.status(400).json({ message: "refreshToken required" });
    }

    const data = await svc.logout(refreshToken);

    return res.status(200).json(data);

  } catch (err: any) {
    console.error("❌ logout error:", err);

    return res.status(err?.status || 500).json({
      message: err?.message || "Internal server error",
    });
  }
}


export async function deleteAccount(req: Request, res: Response) {
  try {
    const header = req.headers.authorization || "";
    const token = header.startsWith("Bearer ") ? header.slice(7) : null;

    if (!token) {
      return res.status(401).json({ message: "Unauthorized" });
    }

    const { valid, payload } =
      verifyTokenSafe<{ id: number }>(token);

    if (!valid) {
      return res.status(401).json({ message: "Invalid token" });
    }

    const data = await svc.deleteAccount(payload!.id);

    return res.status(200).json(data);

  } catch (err: any) {
    console.error("❌ deleteAccount error:", err);

    return res.status(err?.status || 500).json({
      message: err?.message || "Internal server error",
    });
  }
}
