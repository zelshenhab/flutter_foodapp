import '../core/api_client.dart'; // <- provides global `dio`
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> me() async {
    final res = await dio.get('/auth/me');
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final res = await dio.post(
      '/auth/refresh', 
      data: {'refreshToken': refreshToken}
    );
    final data = Map<String, dynamic>.from(res.data);
    
    // Save the new tokens
    if (data.containsKey('accessToken')) {
      await _storage.write(key: 'auth_token', value: data['accessToken']);
    }
    if (data.containsKey('refreshToken')) {
      await _storage.write(key: 'refresh_token', value: data['refreshToken']);
    }
    
    return data;
  }

  Future<void> logout(String refreshToken) async {
    try {
      await dio.post(
        '/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } finally {
      // Always clear local tokens
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'refresh_token');
      await _storage.delete(key: 'user_email');
    }
  }

  Future<void> deleteAccount() async {
    try {
      await dio.delete('/auth/delete-account');
    } finally {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'refresh_token');
      await _storage.delete(key: 'user_email');
    }
  }
  
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }
}