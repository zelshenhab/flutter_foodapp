import 'package:dio/dio.dart';

class Env {
  // Set with --dart-define=API_BASE_URL=...
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // Android emulator default; iOS use localhost
    defaultValue: 'http://10.0.2.2:4000/api',
  );
}

// Shared Dio instance for the whole app
final dio = Dio(
  BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
  ),
);
