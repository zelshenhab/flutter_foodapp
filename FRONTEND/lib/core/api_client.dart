import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Env {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://adameve-gamma.vercel.app/api',
  );
}

final dio = Dio(
  BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
  ),
);

bool _isRedirecting = false;

/// ✅ Setup Dio interceptors globally (SAFE VERSION)
void setupInterceptors({GlobalKey<NavigatorState>? navigatorKey}) {
  const storage = FlutterSecureStorage();

  // 🔥 VERY IMPORTANT — prevent stacking interceptors
  dio.interceptors.clear();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await storage.read(key: 'auth_token');

          if (token != null &&
              token.isNotEmpty &&
              !JwtDecoder.isExpired(token)) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {
          // Ignore storage errors
        }

        handler.next(options);
      },
      onError: (DioException e, handler) async {
        final msg = e.response?.data.toString() ?? e.message ?? '';

        final isUnauthorized =
            e.response?.statusCode == 401 ||
            msg.contains('jwt expired') ||
            msg.contains('TokenExpiredError');

        if (isUnauthorized && !_isRedirecting) {
          _isRedirecting = true;

          try {
            await storage.delete(key: 'auth_token');
          } catch (_) {}

          // 🔥 Navigate SAFELY after frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigatorKey?.currentState?.pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
            _isRedirecting = false;
          });
        }

        handler.next(e);
      },
    ),
  );
}