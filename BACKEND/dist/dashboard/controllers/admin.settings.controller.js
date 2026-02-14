"use strict";
// BACKEND/src/dashboard/controllers/admin.settings.controller.ts
Object.defineProperty(exports, "__esModule", { value: true });
exports.getSettingsHandler = getSettingsHandler;
exports.updateSettingsHandler = updateSettingsHandler;
const admin_settings_service_1 = require("../services/admin.settings.service");
async function getSettingsHandler(_req, res, next) {
    try {
        const settings = await (0, admin_settings_service_1.getAdminSettings)();
        // Frontend expects plain settings object, not array
        res.json({
            notifyAdmins: settings.notifyAdmins,
            testMode: settings.testMode,
            supportEmail: settings.supportEmail,
            restaurantEmail: settings.restaurantEmail,
            businessHours: settings.businessHours,
            maintenanceMode: settings.maintenanceMode,
            maintenanceMessage: settings.maintenanceMessage,
        });
    }
    catch (err) {
        next(err);
    }
}
async function updateSettingsHandler(req, res, next) {
    try {
        const body = req.body;
        const merged = {
            // defaults (so partial body still works)
            notifyAdmins: body.notifyAdmins ?? true,
            testMode: body.testMode ?? false,
            supportEmail: body.supportEmail ?? "",
            restaurantEmail: body.restaurantEmail ?? "",
            businessHours: body.businessHours ?? "",
            maintenanceMode: body.maintenanceMode ?? false,
            maintenanceMessage: body.maintenanceMessage ?? "",
        };
        const saved = await (0, admin_settings_service_1.saveAdminSettings)(merged);
        res.json({
            notifyAdmins: saved.notifyAdmins,
            testMode: saved.testMode,
            supportEmail: saved.supportEmail,
            restaurantEmail: saved.restaurantEmail,
            businessHours: saved.businessHours,
            maintenanceMode: saved.maintenanceMode,
            maintenanceMessage: saved.maintenanceMessage,
        });
    }
    catch (err) {
        next(err);
    }
}
//# sourceMappingURL=admin.settings.controller.js.map