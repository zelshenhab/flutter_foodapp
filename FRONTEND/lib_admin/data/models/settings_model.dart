import 'package:flutter/foundation.dart';

@immutable
class AdminSettings {
  final bool notifyAdmins;
  final bool testMode;
  final String supportPhone;
  final String restaurantEmail;
  final String businessHours;
  final bool maintenanceMode;
  final String maintenanceMessage;

  const AdminSettings({
    required this.notifyAdmins,
    required this.testMode,
    required this.supportPhone,
    required this.restaurantEmail,
    required this.businessHours,
    required this.maintenanceMode,
    required this.maintenanceMessage,
  });

  /// Default settings (used when Reset pressed)
  const AdminSettings.defaults()
      : notifyAdmins = true,
        testMode = false,
        supportPhone = "",
        restaurantEmail = "",
        businessHours = "",
        maintenanceMode = false,
        maintenanceMessage = "";

  AdminSettings copyWith({
    bool? notifyAdmins,
    bool? testMode,
    String? supportPhone,
    String? restaurantEmail,
    String? businessHours,
    bool? maintenanceMode,
    String? maintenanceMessage,
  }) {
    return AdminSettings(
      notifyAdmins: notifyAdmins ?? this.notifyAdmins,
      testMode: testMode ?? this.testMode,
      supportPhone: supportPhone ?? this.supportPhone,
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
      supportPhone: j["supportPhone"] ?? "",
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
      "supportPhone": supportPhone,
      "restaurantEmail": restaurantEmail,
      "businessHours": businessHours,
      "maintenanceMode": maintenanceMode,
      "maintenanceMessage": maintenanceMessage,
    };
  }
}
