// BACKEND/src/dashboard/models/admin.settings.types.ts

export interface AdminSettings {
  notifyAdmins: boolean;
  testMode: boolean;
  supportPhone: string;
  restaurantEmail: string;
  businessHours: string;
  maintenanceMode: boolean;
  maintenanceMessage: string;
}

export interface AdminSettingsRow extends AdminSettings {
  id: number;
}

// Defaults – match Flutter AdminSettings.defaults()
export const defaultAdminSettings: AdminSettings = {
  notifyAdmins: true,
  testMode: false,
  supportPhone: "",
  restaurantEmail: "",
  businessHours: "",
  maintenanceMode: false,
  maintenanceMessage: "",
};
