import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Env {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000/api',
  );
}

final dio = Dio(
  BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
  ),
);

class AuthTokenStore {
  static const _kAccess = 'access_token';

  static Future<void> saveAccessToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kAccess, token);
  }

  static Future<String?> loadAccessToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kAccess);
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kAccess);
  }
}

/// Call this once at app start
Future<void> initApiClient() async {
  final token = await AuthTokenStore.loadAccessToken();
  if (token != null && token.isNotEmpty) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }
}
