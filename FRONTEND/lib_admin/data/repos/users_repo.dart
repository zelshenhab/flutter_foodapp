import '../admin_api_client.dart';

class UsersRepo {
  final AdminApiClient api;
  UsersRepo(this.api);

  Future<Map<String, dynamic>> fetchUsers({int page = 1, int limit = 20}) async {
    final res = await api.get("/users?page=$page&limit=$limit");
    return res;
  }

  Future<Map<String, dynamic>> getUser(int id) async {
    final res = await api.get("/users/$id");
    return res["data"];
  }

  Future<bool> updateUserRole(int userId, String role) async {
    try {
      await api.put("/users/$userId/role", body: {"role": role});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> blockUser(int userId) async {
    try {
      await api.put("/users/$userId/block");
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unblockUser(int userId) async {
    try {
      await api.put("/users/$userId/unblock");
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addUser(String name, String phone, {String role = "customer"}) async {
    try {
      await api.post("/users", body: {
        "name": name,
        "phone": phone,
        "role": role,
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}
