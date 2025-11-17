// BACKEND/src/dashboard/services/admin.settings.service.ts

import { supabase } from "../../core/config/supabase";
import {
  AdminSettings,
  AdminSettingsRow,
  defaultAdminSettings,
} from "../models/admin.settings.types";

const SETTINGS_TABLE = "admin_settings";
const SETTINGS_ID = 1; // Single row with id=1

export async function getAdminSettings(): Promise<AdminSettingsRow> {
  const { data, error } = await supabase
    .from(SETTINGS_TABLE)
    .select("*")
    .eq("id", SETTINGS_ID)
    .maybeSingle();

  if (error) {
    // If table exists but query failed – surface error
    throw error;
  }

  // No row yet: return defaults (you can optionally auto-create row here)
  if (!data) {
    return {
      id: SETTINGS_ID,
      ...defaultAdminSettings,
    };
  }

  return {
    id: data.id,
    notifyAdmins: data.notifyAdmins ?? defaultAdminSettings.notifyAdmins,
    testMode: data.testMode ?? defaultAdminSettings.testMode,
    supportPhone: data.supportPhone ?? defaultAdminSettings.supportPhone,
    restaurantEmail: data.restaurantEmail ?? defaultAdminSettings.restaurantEmail,
    businessHours: data.businessHours ?? defaultAdminSettings.businessHours,
    maintenanceMode: data.maintenanceMode ?? defaultAdminSettings.maintenanceMode,
    maintenanceMessage:
      data.maintenanceMessage ?? defaultAdminSettings.maintenanceMessage,
  };
}

export async function saveAdminSettings(
  payload: AdminSettings
): Promise<AdminSettingsRow> {
  const upsertPayload = {
    id: SETTINGS_ID,
    notifyAdmins: payload.notifyAdmins,
    testMode: payload.testMode,
    supportPhone: payload.supportPhone,
    restaurantEmail: payload.restaurantEmail,
    businessHours: payload.businessHours,
    maintenanceMode: payload.maintenanceMode,
    maintenanceMessage: payload.maintenanceMessage,
  };

  const { data, error } = await supabase
    .from(SETTINGS_TABLE)
    .upsert(upsertPayload, {
      onConflict: "id",
    })
    .select("*")
    .single();

  if (error) {
    throw error;
  }

  return {
    id: data.id,
    notifyAdmins: data.notifyAdmins,
    testMode: data.testMode,
    supportPhone: data.supportPhone,
    restaurantEmail: data.restaurantEmail,
    businessHours: data.businessHours,
    maintenanceMode: data.maintenanceMode,
    maintenanceMessage: data.maintenanceMessage,
  };
}
