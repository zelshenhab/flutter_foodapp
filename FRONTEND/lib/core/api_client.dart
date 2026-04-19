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

final storage = const FlutterSecureStorage();

bool _isRefreshing = false;
bool _isRedirecting = false;
final List<QueuedRequest> _queuedRequests = [];

class QueuedRequest {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;
  final Completer<Response> completer;
  
  QueuedRequest({
    required this.requestOptions,
    required this.handler,
    required this.completer,
  });
}

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

      /// Handle responses and errors
      onResponse: (response, handler) {
        handler.next(response);
      },

      /// Handle errors with token refresh
      onError: (DioException e, handler) async {
        final statusCode = e.response?.statusCode;
        
        // Only handle 401 errors
        if (statusCode != 401) {
          return handler.next(e);
        }

        // Check if this is a refresh request to avoid loops
        if (e.requestOptions.path.contains('/auth/refresh')) {
          // Refresh failed, logout
          await storage.delete(key: 'auth_token');
          await storage.delete(key: 'refresh_token');
          
          if (!_isRedirecting && navigatorKey?.currentState != null) {
            _isRedirecting = true;
            navigatorKey!.currentState!.pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
          return handler.reject(e);
        }

        try {
          // If already refreshing, queue this request
          if (_isRefreshing) {
            final completer = Completer<Response>();
            _queuedRequests.add(QueuedRequest(
              requestOptions: e.requestOptions,
              handler: handler,
              completer: completer,
            ));
            await completer.future;
            return;
          }

          _isRefreshing = true;
          
          final refreshToken = await storage.read(key: 'refresh_token');
          if (refreshToken == null) {
            throw Exception("No refresh token");
          }

          // Request new tokens
          final refreshResponse = await dio.post(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          final newAccessToken = refreshResponse.data['accessToken'];
          final newRefreshToken = refreshResponse.data['refreshToken'];

          if (newAccessToken == null) {
            throw Exception("Invalid refresh response");
          }

          // Save new tokens
          await storage.write(key: 'auth_token', value: newAccessToken);
          if (newRefreshToken != null) {
            await storage.write(key: 'refresh_token', value: newRefreshToken);
          }

          // Update dio headers for future requests
          dio.options.headers['Authorization'] = 'Bearer $newAccessToken';

          // Retry all queued requests
          for (final queued in _queuedRequests) {
            final opts = Options(
              method: queued.requestOptions.method,
              headers: {
                ...queued.requestOptions.headers,
                'Authorization': 'Bearer $newAccessToken',
              },
            );
            
            try {
              final response = await dio.request(
                queued.requestOptions.path,
                data: queued.requestOptions.data,
                queryParameters: queued.requestOptions.queryParameters,
                options: opts,
              );
              queued.completer.complete(response);
            } catch (err) {
              queued.completer.completeError(err);
            }
          }
          _queuedRequests.clear();

          // Retry original request
          final opts = Options(
            method: e.requestOptions.method,
            headers: {
              ...e.requestOptions.headers,
              'Authorization': 'Bearer $newAccessToken',
            },
          );
          
          final response = await dio.request(
            e.requestOptions.path,
            data: e.requestOptions.data,
            queryParameters: e.requestOptions.queryParameters,
            options: opts,
          );
          
          _isRefreshing = false;
          return handler.resolve(response);
          
        } catch (refreshError) {
          // Refresh failed, logout user
          _isRefreshing = false;
          _queuedRequests.clear();
          
          await storage.delete(key: 'auth_token');
          await storage.delete(key: 'refresh_token');
          
          if (!_isRedirecting && navigatorKey?.currentState != null) {
            _isRedirecting = true;
            navigatorKey!.currentState!.pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
          
          return handler.reject(e);
        }
      },
    ),
  );
}