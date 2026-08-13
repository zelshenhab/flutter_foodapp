import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Lightweight auth check used by guest UX (menu/cart/checkout).
class AuthSession {
  AuthSession._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }
}
