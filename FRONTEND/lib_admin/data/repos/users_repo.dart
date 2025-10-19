import '../admin_api_client.dart';

class AdminUser {
  final String id;
  final String name;
  final String phone;
  final String role;
  AdminUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
  });

  factory AdminUser.fromJson(Map<String, dynamic> j) =>
      AdminUser(id: j['id'], name: j['name'], phone: j['phone'], role: j['role']);
}

class UsersRepo {
  final AdminApiClient api;
  UsersRepo(this.api);

  Future<List<AdminUser>> fetchUsers() async {
    final data = await api.getList('/users');
    return data.map((e) => AdminUser.fromJson(e)).toList();
  }

  Future<bool> addUser(String name, String phone, {String role = 'customer'}) {
    return api.post('/users', {'name': name, 'phone': phone, 'role': role});
  }

  Future<bool> updateUserRole(String id, String role) {
    return api.patch('/users/$id', {'role': role});
  }

  Future<bool> blockUser(String id) => api.patch('/users/$id', {'blocked': true});
}
