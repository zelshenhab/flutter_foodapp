// BACKEND/src/dashboard/controllers/admin.settings.controller.ts

import { Request, Response, NextFunction } from "express";
import {
  getAdminSettings,
  saveAdminSettings,
} from "../services/admin.settings.service";
import { AdminSettings } from "../models/admin.settings.types";

export async function getSettingsHandler(
  _req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const settings = await getAdminSettings();
    // Frontend expects plain settings object, not array
    res.json({
      notifyAdmins: settings.notifyAdmins,
      testMode: settings.testMode,
      supportPhone: settings.supportPhone,
      restaurantEmail: settings.restaurantEmail,
      businessHours: settings.businessHours,
      maintenanceMode: settings.maintenanceMode,
      maintenanceMessage: settings.maintenanceMessage,
    });
  } catch (err) {
    next(err);
  }
}

export async function updateSettingsHandler(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const body = req.body as Partial<AdminSettings>;

    const merged: AdminSettings = {
      // defaults (so partial body still works)
      notifyAdmins: body.notifyAdmins ?? true,
      testMode: body.testMode ?? false,
      supportPhone: body.supportPhone ?? "",
      restaurantEmail: body.restaurantEmail ?? "",
      businessHours: body.businessHours ?? "",
      maintenanceMode: body.maintenanceMode ?? false,
      maintenanceMessage: body.maintenanceMessage ?? "",
    };

    const saved = await saveAdminSettings(merged);

    res.json({
      notifyAdmins: saved.notifyAdmins,
      testMode: saved.testMode,
      supportPhone: saved.supportPhone,
      restaurantEmail: saved.restaurantEmail,
      businessHours: saved.businessHours,
      maintenanceMode: saved.maintenanceMode,
      maintenanceMessage: saved.maintenanceMessage,
    });
  } catch (err) {
    next(err);
  }
}
