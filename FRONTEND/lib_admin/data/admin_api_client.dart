// lib_admin/data/admin_api_client.dart
import 'dart:async';

/// عميل Admin "موك" لكن بحالة داخلية (stateful)
/// - بيحتفظ بقائمة مستخدمين في الذاكرة
/// - getList/post/patch/delete بتعدّل فعليًا في الذاكرة
class AdminApiClient {
  final String baseUrl;
  final String? token;

  const AdminApiClient({required this.baseUrl, this.token});

  /// Factory مريحة لو عايز موك سريع
  factory AdminApiClient.mock() => const AdminApiClient(baseUrl: 'mock');

  // ======== ذاكرة داخلية للمستخدمين ========
  static final List<Map<String, dynamic>> _users = List.generate(
    8,
    (i) => {
      'id': 'usr_$i',
      'name': 'Пользователь $i',
      'phone': '+7 900 111-22-0$i',
      'role': i == 0 ? 'admin' : (i.isEven ? 'manager' : 'customer'),
      'blocked': i == 5, // مثال: مستخدم محظور
      'createdAt': DateTime.now()
          .subtract(Duration(hours: i * 3))
          .toIso8601String(),
    },
  );

  // ======== GETs ========
  Future<List<Map<String, dynamic>>> getList(String path) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (path == '/users') {
      // رجّع نسخة مرتبة بالأحدث
      final copy = List<Map<String, dynamic>>.from(_users);
      copy.sort(
        (a, b) => DateTime.parse(
          b['createdAt'],
        ).compareTo(DateTime.parse(a['createdAt'])),
      );
      return copy;
    }

    // تقدر تزود مسارات تانية لاحقًا
    return [];
  }

  // ======== POST ========
  Future<bool> post(String path, Map<String, dynamic> body) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (path == '/users') {
      // إضافة مستخدم جديد
      final id = 'usr_${DateTime.now().millisecondsSinceEpoch}';
      final name = (body['name'] ?? '').toString();
      final phone = (body['phone'] ?? '').toString();
      final role = (body['role'] ?? 'customer').toString();

      _users.insert(0, {
        'id': id,
        'name': name,
        'phone': phone,
        'role': role,
        'blocked': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return true;
    }

    return true; // افتراضي
  }

  // ======== PATCH ========
  Future<bool> patch(String path, Map<String, dynamic> body) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // أمثلة مسارات متوقعة:
    // /users/:id        -> تحديث عام (role / blocked ...)
    // /users/:id/block  -> حظر
    // /users/:id/unblock-> إلغاء الحظر

    if (path.startsWith('/users/')) {
      final parts = path.split('/');
      if (parts.length < 3) return false;
      final userId = parts[2];

      // ابحث عن المستخدم
      final idx = _users.indexWhere((u) => u['id'] == userId);
      if (idx == -1) return false;

      // عمليات خاصة بالحظر
      if (parts.length == 4) {
        final action = parts[3];
        if (action == 'block') {
          _users[idx]['blocked'] = true;
          return true;
        } else if (action == 'unblock') {
          _users[idx]['blocked'] = false;
          return true;
        }
      }

      // تحديثات عامة: role / blocked / name / phone ...
      if (body.containsKey('role')) {
        _users[idx]['role'] = body['role'];
      }
      if (body.containsKey('blocked')) {
        _users[idx]['blocked'] = body['blocked'] == true;
      }
      if (body.containsKey('name')) {
        _users[idx]['name'] = body['name'] ?? _users[idx]['name'];
      }
      if (body.containsKey('phone')) {
        _users[idx]['phone'] = body['phone'] ?? _users[idx]['phone'];
      }

      return true;
    }

    return true;
  }

  // ======== DELETE (اختياري) ========
  Future<bool> delete(String path) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // مثال: /users/:id
    if (path.startsWith('/users/')) {
      final id = path.split('/').last;
      _users.removeWhere((u) => u['id'] == id);
      return true;
    }

    return true;
  }
}
