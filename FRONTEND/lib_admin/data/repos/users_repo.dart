import 'package:flutter/widgets.dart';

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
      final res = await api.put("/users/$userId/role", body: {"role": role});
      return res["success"] == true;
    } catch (_) {
      return false;
    }
  }

Future<bool> blockUser(int userId) async {
  try {
    debugPrint('🛑 Attempting to block user $userId');
    
    // Send empty object instead of null body
    final res = await api.put("/users/$userId/block", body: {});
    
    debugPrint('✅ Block user response: $res');
    return res["success"] == true;
  } catch (e) {
    debugPrint('❌ Error blocking user $userId: $e');
    return false;
  }
}

Future<bool> unblockUser(int userId) async {
    try {
      debugPrint('🛑 Attempting to unblock user $userId');
      
      // Send empty object instead of null body
      final res = await api.put("/users/$userId/unblock", body: {});
      
      debugPrint('✅ Unblock user response: $res');
      return res["success"] == true;
    } catch (e) {
      debugPrint('❌ Error unblocking user $userId: $e');
      return false;
    }
  }

  Future<bool> addUser(String name, String phone, {String role = "customer"}) async {
    try {
      final res = await api.post("/users", body: {
        "name": name,
        "phone": phone,
        "role": role,
      });
      return res["success"] == true;
    } catch (_) {
      return false;
    }
  }
}