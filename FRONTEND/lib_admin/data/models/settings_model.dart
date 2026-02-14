import 'package:flutter/foundation.dart';

@immutable
class AdminSettings {
  final bool notifyAdmins;
  final bool testMode;
  final String supportEmail;
  final String restaurantEmail;
  final String businessHours;
  final bool maintenanceMode;
  final String maintenanceMessage;

  const AdminSettings({
    required this.notifyAdmins,
    required this.testMode,
    required this.supportEmail,
    required this.restaurantEmail,
    required this.businessHours,
    required this.maintenanceMode,
    required this.maintenanceMessage,
  });

  /// Default settings (used when Reset pressed)
  const AdminSettings.defaults()
      : notifyAdmins = true,
        testMode = false,
        supportEmail = "adamandeve@mail.ru",
        restaurantEmail = "",
        businessHours = "",
        maintenanceMode = false,
        maintenanceMessage = "";

  AdminSettings copyWith({
    bool? notifyAdmins,
    bool? testMode,
    String? supportEmail,
    String? restaurantEmail,
    String? businessHours,
    bool? maintenanceMode,
    String? maintenanceMessage,
  }) {
    return AdminSettings(
      notifyAdmins: notifyAdmins ?? this.notifyAdmins,
      testMode: testMode ?? this.testMode,
      supportEmail: supportEmail ?? this.supportEmail,
      restaurantEmail: restaurantEmail ?? this.restaurantEmail,
      businessHours: businessHours ?? this.businessHours,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      maintenanceMessage: maintenanceMessage ?? this.maintenanceMessage,
    );
  }

  factory AdminSettings.fromJson(Map<String, dynamic> j) {
    return AdminSettings(
      notifyAdmins: j["notifyAdmins"] ?? true,
      testMode: j["testMode"] ?? false,
      supportEmail: j["supportEmail"] ?? "",
      restaurantEmail: j["restaurantEmail"] ?? "",
      businessHours: j["businessHours"] ?? "",
      maintenanceMode: j["maintenanceMode"] ?? false,
      maintenanceMessage: j["maintenanceMessage"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "notifyAdmins": notifyAdmins,
      "testMode": testMode,
      "supportEmail": supportEmail,
      "restaurantEmail": restaurantEmail,
      "businessHours": businessHours,
      "maintenanceMode": maintenanceMode,
      "maintenanceMessage": maintenanceMessage,
    };
  }
}
