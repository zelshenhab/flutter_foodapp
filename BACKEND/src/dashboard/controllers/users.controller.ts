import { Request, Response } from "express";
import { blockUser, countUsers, fetchUser, fetchUsers, unblockUser, updateUserRole } from "../services/users.service";


export async function getUsers(req: Request, res: Response) {
  try {
    const page = Number(req.query.page) || 1;
    const limit = Number(req.query.limit) || 20;
    const offset = (page - 1) * limit;

    const users = await fetchUsers(limit, offset);
    const total = await countUsers();

    return res.json({
      data: users,
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit)
    });
  } catch (e) {
    console.error("GET USERS ERROR:", e);
    return res.status(500).json({ error: "Failed to fetch users" });
  }
}


export async function getUser(req: Request, res: Response) {
  try {
    const user = await fetchUser(Number(req.params.id));
    return res.json({ data: user });
  } catch (e) {
    console.error("GET USER ERROR:", e);
    return res.status(500).json({ error: "Failed to fetch user" });
  }
}

export async function blockUserController(req: Request, res: Response) {
  try {
    console.log('🛑 BLOCK USER CONTROLLER - START');
    const userId = Number(req.params.id);
    
    const result = await blockUser(userId);
    console.log('✅ BLOCK USER CONTROLLER - SUCCESS:', result);
    
    return res.json({ success: true });
  } catch (e) {
    console.error("❌ BLOCK USER CONTROLLER - CAUGHT ERROR:", e);
    // Don't modify the error, let it pass through to errorHandler
    throw e;
  }
}

export async function unblockUserController(req: Request, res: Response) {
  try {
    await unblockUser(Number(req.params.id));
    return res.json({ success: true });
  } catch (e) {
    console.error("UNBLOCK USER ERROR:", e);
    return res.status(500).json({ error: "Failed to unblock user" });
  }
}

export async function updateRoleController(req: Request, res: Response) {
  try {
    const { role } = req.body;
    await updateUserRole(Number(req.params.id), role);
    return res.json({ success: true });
  } catch (e) {
    console.error("UPDATE ROLE ERROR:", e);
    return res.status(500).json({ error: "Failed to update role" });
  }
}
