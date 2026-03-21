import '../core/api_client.dart';
import 'package:flutter/foundation.dart';

class ProfileRepository {
  const ProfileRepository();

  Future<Map<String, dynamic>> getMe() async {
    final res = await dio.get('/users/me');
    final raw = res.data;

    // 🔍 Debugging helper
    debugPrint('🧩 /users/me response: $raw');

    if (raw == null) throw Exception('Empty response from server');

    // Handle both {data: {...}} and {...} shapes
    final data = raw['data'] ?? raw;

    if (data is! Map) {
      throw Exception('Unexpected response format: $data');
    }

    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> updateMe({
    String? name,
    String? surname,
  }) async {
    final res = await dio.put('/users/me', data: {
      if (name != null && name.isNotEmpty) 'name': name,
      if (surname != null && surname.isNotEmpty) 'surname': surname,
    });

    final raw = res.data;
    final data = raw['data'] ?? raw;

    if (data is! Map) {
      throw Exception('Unexpected updateMe format: $data');
    }

    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> setAvatarUrl(String avatarUrl) async {
    final res = await dio.put('/users/me/avatar', data: {'avatarUrl': avatarUrl});
    final raw = res.data;
    final data = raw['data'] ?? raw;
    if (data is! Map) {
      throw Exception('Unexpected avatar response: $data');
    }
    return Map<String, dynamic>.from(data);
  }

  // Public profile
  Future<Map<String, dynamic>> getById(int id) async {
    final res = await dio.get('/users/$id');
    final raw = res.data;
    final data = raw['data'] ?? raw;
    if (data is! Map) {
      throw Exception('Unexpected profileById format: $data');
    }
    return Map<String, dynamic>.from(data);
  }
}
