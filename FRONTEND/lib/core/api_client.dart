import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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

/// ✅ Setup Dio interceptors globally
void setupInterceptors({GlobalKey<NavigatorState>? navigatorKey}) {
  const storage = FlutterSecureStorage();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'auth_token');
        if (token != null && !JwtDecoder.isExpired(token)) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException e, handler) async {
        final msg = e.response?.data.toString() ?? e.message ?? '';

        if (e.response?.statusCode == 401 ||
            msg.contains('jwt expired') ||
            msg.contains('TokenExpiredError')) {
          debugPrint('⚠️ JWT expired — redirecting to login');

          await storage.delete(key: 'auth_token');

          if (navigatorKey?.currentState != null) {
            navigatorKey!.currentState!.pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
        }

        handler.next(e);
      },
    ),
  );
}
