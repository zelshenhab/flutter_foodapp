import 'package:flutter/foundation.dart';
import '../admin_api_client.dart';

/// نموذج إعدادات لوحة التحكم
@immutable
class AdminSettings {
  final bool notifyAdmins;
  final bool testMode;

  const AdminSettings({required this.notifyAdmins, required this.testMode});

  AdminSettings copyWith({bool? notifyAdmins, bool? testMode}) {
    return AdminSettings(
      notifyAdmins: notifyAdmins ?? this.notifyAdmins,
      testMode: testMode ?? this.testMode,
    );
  }

  factory AdminSettings.fromJson(Map<String, dynamic> j) => AdminSettings(
    notifyAdmins: (j['notifyAdmins'] as bool?) ?? true,
    testMode: (j['testMode'] as bool?) ?? false,
  );

  Map<String, dynamic> toJson() => {
    'notifyAdmins': notifyAdmins,
    'testMode': testMode,
  };
}

/// مستودع إعدادات (Mock) — جاهز للاستبدال باتصال حقيقي لاحقًا
class SettingsRepo {
  final AdminApiClient api;
  SettingsRepo(this.api);

  /// جلب الإعدادات الحالية
  Future<AdminSettings> fetchSettings() async {
    // في الـMock: هنستخدم endpoint وهمي
    final data = await api.getList('/settings');
    // لو السيرفر رجّع قائمة فاضية — رجّع قيم افتراضية
    if (data.isEmpty) {
      return const AdminSettings(notifyAdmins: true, testMode: false);
    }
    return AdminSettings.fromJson(data.first);
  }

  /// حفظ الإعدادات كاملة
  Future<bool> saveSettings(AdminSettings s) async {
    // في API حقيقي ممكن يكون PATCH/PUT على /settings
    return api.patch('/settings', s.toJson());
  }

  /// تفعيل/إلغاء إشعارات المدراء
  Future<bool> toggleNotifyAdmins(bool enabled) async {
    return api.patch('/settings', {'notifyAdmins': enabled});
  }

  /// تفعيل/إلغاء وضع الاختبار
  Future<bool> toggleTestMode(bool enabled) async {
    return api.patch('/settings', {'testMode': enabled});
  }
}
