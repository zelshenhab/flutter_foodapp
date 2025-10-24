import 'package:flutter/foundation.dart';

@immutable
class AdminSettings {
  final bool notifyAdmins;
  final bool testMode;

  const AdminSettings({
    required this.notifyAdmins,
    required this.testMode,
  });

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
