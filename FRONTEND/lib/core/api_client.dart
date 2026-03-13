import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Env {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://adam-eve-ebon.vercel.app/api',
  );
}

final dio = Dio(
  BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
  ),
);

final storage = const FlutterSecureStorage();

bool _isRefreshing = false;
bool _isRedirecting = false;

void setupInterceptors({GlobalKey<NavigatorState>? navigatorKey}) {
  dio.interceptors.clear();

  dio.interceptors.add(
    InterceptorsWrapper(
      /// Attach access token
      onRequest: (options, handler) async {
        try {
          final token = await storage.read(key: 'auth_token');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {}

        handler.next(options);
      },

      /// Handle errors
      onError: (DioException e, handler) async {
        final statusCode = e.response?.statusCode;

        if (statusCode == 401) {
          try {
            /// prevent multiple refresh calls
            if (_isRefreshing) {
              return handler.next(e);
            }

            _isRefreshing = true;

            final refreshToken = await storage.read(key: 'refresh_token');

            if (refreshToken == null) {
              throw Exception("No refresh token");
            }

            /// request new tokens
            final response = await dio.post(
              '/auth/refresh',
              data: {'refreshToken': refreshToken},
            );

            final newAccessToken = response.data['accessToken'];
            final newRefreshToken = response.data['refreshToken'];

            if (newAccessToken == null) {
              throw Exception("Invalid refresh response");
            }

            /// save new tokens
            await storage.write(key: 'auth_token', value: newAccessToken);

            if (newRefreshToken != null) {
              await storage.write(
                key: 'refresh_token',
                value: newRefreshToken,
              );
            }

            /// retry original request
            final options = e.requestOptions;

            options.headers['Authorization'] = 'Bearer $newAccessToken';

            final cloneReq = await dio.fetch(options);

            _isRefreshing = false;

            return handler.resolve(cloneReq);
          } catch (_) {
            _isRefreshing = false;

            /// refresh failed → logout
            await storage.delete(key: 'auth_token');
            await storage.delete(key: 'refresh_token');

            if (!_isRedirecting) {
              _isRedirecting = true;

              if (navigatorKey?.currentState != null) {
                navigatorKey!.currentState!.pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            }
          }
        }
        handler.next(e);
      },
    ),
  );
}