"use strict";
// BACKEND/src/dashboard/services/admin.settings.service.ts
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAdminSettings = getAdminSettings;
exports.saveAdminSettings = saveAdminSettings;
const supabase_1 = require("../../core/config/supabase");
const admin_settings_types_1 = require("../models/admin.settings.types");
const SETTINGS_TABLE = "admin_settings";
const SETTINGS_ID = 1; // Single row with id=1
async function getAdminSettings() {
    const { data, error } = await supabase_1.supabase
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
            ...admin_settings_types_1.defaultAdminSettings,
        };
    }
    return {
        id: data.id,
        notifyAdmins: data.notifyAdmins ?? admin_settings_types_1.defaultAdminSettings.notifyAdmins,
        testMode: data.testMode ?? admin_settings_types_1.defaultAdminSettings.testMode,
        supportEmail: data.supportEmail ?? admin_settings_types_1.defaultAdminSettings.supportEmail,
        restaurantEmail: data.restaurantEmail ?? admin_settings_types_1.defaultAdminSettings.restaurantEmail,
        businessHours: data.businessHours ?? admin_settings_types_1.defaultAdminSettings.businessHours,
        maintenanceMode: data.maintenanceMode ?? admin_settings_types_1.defaultAdminSettings.maintenanceMode,
        maintenanceMessage: data.maintenanceMessage ?? admin_settings_types_1.defaultAdminSettings.maintenanceMessage,
    };
}
async function saveAdminSettings(payload) {
    const upsertPayload = {
        id: SETTINGS_ID,
        notifyAdmins: payload.notifyAdmins,
        testMode: payload.testMode,
        supportEmail: payload.supportEmail,
        restaurantEmail: payload.restaurantEmail,
        businessHours: payload.businessHours,
        maintenanceMode: payload.maintenanceMode,
        maintenanceMessage: payload.maintenanceMessage,
    };
    const { data, error } = await supabase_1.supabase
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
        supportEmail: data.supportEmail,
        restaurantEmail: data.restaurantEmail,
        businessHours: data.businessHours,
        maintenanceMode: data.maintenanceMode,
        maintenanceMessage: data.maintenanceMessage,
    };
}
//# sourceMappingURL=admin.settings.service.js.map