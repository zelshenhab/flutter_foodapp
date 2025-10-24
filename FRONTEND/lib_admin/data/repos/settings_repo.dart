import 'dart:async';
import 'package:flutter/foundation.dart' show immutable;

/// لو عندك عميل API حقيقي لاحقًا، إربطه هنا
/// حالياً بنستخدم تخزين مؤقت داخل الذاكرة (mock) علشان الديمو يعمل فوراً.
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

  const AdminSettings.defaults()
      : notifyAdmins = true,
        testMode = false,
        supportPhone = '+7 (900) 000-00-00',
        restaurantEmail = 'info@restaurant.ru',
        businessHours = 'Ежедневно: 10:00 — 22:00',
        maintenanceMode = false,
        maintenanceMessage = 'Технические работы. Пожалуйста, зайдите позже.';

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

  factory AdminSettings.fromJson(Map<String, dynamic> j) => AdminSettings(
        notifyAdmins: (j['notifyAdmins'] as bool?) ?? true,
        testMode: (j['testMode'] as bool?) ?? false,
        supportPhone: (j['supportPhone'] as String?) ?? '',
        restaurantEmail: (j['restaurantEmail'] as String?) ?? '',
        businessHours: (j['businessHours'] as String?) ?? '',
        maintenanceMode: (j['maintenanceMode'] as bool?) ?? false,
        maintenanceMessage: (j['maintenanceMessage'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'notifyAdmins': notifyAdmins,
        'testMode': testMode,
        'supportPhone': supportPhone,
        'restaurantEmail': restaurantEmail,
        'businessHours': businessHours,
        'maintenanceMode': maintenanceMode,
        'maintenanceMessage': maintenanceMessage,
      };
}

class SettingsRepo {
  // بديل مؤقت: تخزين داخل الذاكرة (يشبه قاعدة بيانات صغيرة)
  static AdminSettings _mem = const AdminSettings.defaults();
  static bool _loadedOnce = false;

  Future<AdminSettings> fetchSettings() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!_loadedOnce) {
      _loadedOnce = true;
      _mem = const AdminSettings.defaults();
    }
    return _mem;
  }

  Future<bool> saveSettings(AdminSettings s) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mem = s;
    return true;
  }

  // مساعدات لو حبيت تستخدم واجهات جزئية لاحقًا
  Future<bool> toggleNotifyAdmins(bool v) => saveSettings(_mem.copyWith(notifyAdmins: v));
  Future<bool> toggleTestMode(bool v) => saveSettings(_mem.copyWith(testMode: v));
}
