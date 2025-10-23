import '../admin_api_client.dart';

/// نموذج المستخدم داخل لوحة التحكم (Admin Dashboard)
class AdminUser {
  final String id;
  final String name;
  final String phone;
  final String role;
  final bool blocked;
  final DateTime? createdAt;

  AdminUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.blocked,
    this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> j) {
    DateTime? date;
    if (j['createdAt'] != null) {
      try {
        date = DateTime.parse(j['createdAt']);
      } catch (_) {
        date = null;
      }
    }
    return AdminUser(
      id: j['id'].toString(),
      name: (j['name'] ?? '').toString(),
      phone: (j['phone'] ?? '').toString(),
      role: (j['role'] ?? 'customer').toString(),
      blocked: (j['blocked'] ?? false) as bool,
      createdAt: date,
    );
  }
}

/// مستودع إدارة المستخدمين (Admin)
class UsersRepo {
  final AdminApiClient api;
  UsersRepo(this.api);

  /// جلب جميع المستخدمين (مترتبين بالأحدث)
  Future<List<AdminUser>> fetchUsers() async {
    final data = await api.getList('/users');
    final list = data.map((e) => AdminUser.fromJson(e)).toList();
    list.sort(
      (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
        a.createdAt ?? DateTime.now(),
      ),
    );
    return list;
  }

  /// إضافة مستخدم جديد
  Future<bool> addUser(
    String name,
    String phone, {
    String role = 'customer',
  }) async {
    try {
      await api.post('/users', {'name': name, 'phone': phone, 'role': role});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// تعديل دور المستخدم
  Future<bool> updateUserRole(String id, String role) async {
    try {
      await api.patch('/users/$id', {'role': role});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// حظر المستخدم
  Future<bool> blockUser(String id) async {
    try {
      await api.patch('/users/$id', {'blocked': true});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// إلغاء حظر المستخدم
  Future<bool> unblockUser(String id) async {
    try {
      await api.patch('/users/$id', {'blocked': false});
      return true;
    } catch (_) {
      return false;
    }
  }
}
