import '../admin_api_client.dart';
import 'package:flutter/material.dart';

import '../models/settings_model.dart';

class SettingsRepo {
  final AdminApiClient api;

  SettingsRepo(this.api);

  Future<AdminSettings> fetchSettings() async {
    final res = await api.get("/settings");
    return AdminSettings.fromJson(res);
  }

  Future<bool> saveSettings(AdminSettings s) async {
    try {
      await api.put("/settings", body: s.toJson());
      return true;
    } catch (e) {
      debugPrint("SETTINGS SAVE ERROR: $e");
      return false;
    }
  }
  

}
