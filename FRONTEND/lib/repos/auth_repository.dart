import 'package:dio/dio.dart';
import '../core/api_client.dart'; // <- provides global `dio`

class AuthRepository {
  Future<Map<String, dynamic>> me() async {
    final res = await dio.get('/auth/me');
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final res = await dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
    return Map<String, dynamic>.from(res.data);
  }
}
