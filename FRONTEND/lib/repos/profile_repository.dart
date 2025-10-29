import '../core/api_client.dart';

class ProfileRepository {
  const ProfileRepository();

  Future<Map<String, dynamic>> getMe() async {
    final res = await dio.get('/users/me');
    return Map<String, dynamic>.from(res.data['data'] as Map);
  }

  Future<Map<String, dynamic>> updateMe({
    String? name,
    String? surname,
  }) async {
    final res = await dio.put('/users/me', data: {
      if (name != null) 'name': name
          });
    return Map<String, dynamic>.from(res.data['data'] as Map);
  }

  Future<Map<String, dynamic>> setAvatarUrl(String avatarUrl) async {
    final res = await dio.put('/users/me/avatar', data: {'avatarUrl': avatarUrl});
    return Map<String, dynamic>.from(res.data['data'] as Map);
  }

  // Public profile
  Future<Map<String, dynamic>> getById(int id) async {
    final res = await dio.get('/users/$id');
    return Map<String, dynamic>.from(res.data['data'] as Map);
  }
}
