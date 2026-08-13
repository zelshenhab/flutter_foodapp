import 'dart:async';

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

/// Dio without auth interceptors — used only for `/auth/refresh`.
final Dio _refreshDio = Dio(
  BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
  ),
);

final storage = const FlutterSecureStorage();

bool _isRedirecting = false;

/// Single-flight refresh lock (prevents refresh-token rotation races).
Completer<String>? _refreshLock;

void resetAuthRedirectFlag() {
  _isRedirecting = false;
}

bool _isAuthRefreshPath(String path) => path.contains('/auth/refresh');

bool _shouldSkipRefresh(RequestOptions options) {
  final path = options.path;
  if (_isAuthRefreshPath(path)) return true;
  if (path.contains('/auth/otp')) return true;
  if (options.extra['skipAuthRefresh'] == true) return true;
  return false;
}

Future<void> _clearTokens() async {
  await storage.delete(key: 'auth_token');
  await storage.delete(key: 'refresh_token');
  dio.options.headers.remove('Authorization');
}

Future<void> _redirectToLogin(GlobalKey<NavigatorState>? navigatorKey) async {
  if (_isRedirecting) return;
  if (navigatorKey?.currentState == null) return;

  _isRedirecting = true;
  navigatorKey!.currentState!.pushNamedAndRemoveUntil(
    '/login',
    (route) => false,
  );
}

/// Refresh access token using the stored refresh token.
/// Concurrent callers share one in-flight request (safe with token rotation).
Future<String> refreshAccessToken() async {
  final existing = _refreshLock;
  if (existing != null) {
    return existing.future;
  }

  final completer = Completer<String>();
  _refreshLock = completer;

  try {
    final refreshToken = await storage.read(key: 'refresh_token');
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No refresh token');
    }

    final refreshResponse = await _refreshDio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    final data = refreshResponse.data;
    final Map<String, dynamic> map = data is Map<String, dynamic>
        ? data
        : Map<String, dynamic>.from(data as Map);

    final newAccessToken = map['accessToken']?.toString();
    final newRefreshToken = map['refreshToken']?.toString();

    if (newAccessToken == null || newAccessToken.isEmpty) {
      throw Exception('Invalid refresh response');
    }

    await storage.write(key: 'auth_token', value: newAccessToken);
    if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
      await storage.write(key: 'refresh_token', value: newRefreshToken);
    }

    dio.options.headers['Authorization'] = 'Bearer $newAccessToken';
    resetAuthRedirectFlag();

    completer.complete(newAccessToken);
    return newAccessToken;
  } catch (e) {
    if (!completer.isCompleted) {
      completer.completeError(e);
    }
    rethrow;
  } finally {
    if (identical(_refreshLock, completer)) {
      _refreshLock = null;
    }
  }
}

/// Call on cold start / app resume so an expired access token is renewed
/// before the user hits a 401 wall.
Future<bool> ensureFreshSession() async {
  final refreshToken = await storage.read(key: 'refresh_token');
  final accessToken = await storage.read(key: 'auth_token');

  // Guest, or leftover access token without refresh → stay guest, no refresh attempt.
  if (refreshToken == null || refreshToken.isEmpty) {
    if (accessToken != null && accessToken.isNotEmpty) {
      await storage.delete(key: 'auth_token');
      dio.options.headers.remove('Authorization');
    }
    return false;
  }

  try {
    await refreshAccessToken();
    return true;
  } catch (e) {
    debugPrint('ensureFreshSession failed: $e');
    return false;
  }
}

void setupInterceptors({GlobalKey<NavigatorState>? navigatorKey}) {
  dio.interceptors.clear();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.extra['skipAuthRefresh'] == true ||
            _isAuthRefreshPath(options.path)) {
          options.headers.remove('Authorization');
          return handler.next(options);
        }

        try {
          final token = await storage.read(key: 'auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {}
        handler.next(options);
      },
      onResponse: (response, handler) => handler.next(response),
      onError: (DioException e, handler) async {
        final statusCode = e.response?.statusCode;
        if (statusCode != 401) {
          return handler.next(e);
        }

        // OTP / refresh endpoints: never try another refresh.
        if (_shouldSkipRefresh(e.requestOptions)) {
          if (_isAuthRefreshPath(e.requestOptions.path)) {
            await _clearTokens();
            await _redirectToLogin(navigatorKey);
          }
          return handler.reject(e);
        }

        // Guest / no session: pass the 401 through without refresh or login redirect.
        final refreshToken = await storage.read(key: 'refresh_token');
        if (refreshToken == null || refreshToken.isEmpty) {
          return handler.next(e);
        }

        try {
          final newAccessToken = await refreshAccessToken();

          final request = e.requestOptions;
          request.headers['Authorization'] = 'Bearer $newAccessToken';

          final response = await dio.fetch(request);
          return handler.resolve(response);
        } catch (refreshError) {
          debugPrint('Token refresh failed: $refreshError');
          await _clearTokens();
          await _redirectToLogin(navigatorKey);
          return handler.reject(e);
        }
      },
    ),
  );
}
