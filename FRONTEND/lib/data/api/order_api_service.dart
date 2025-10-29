import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/api_client.dart';

class OrderApiService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> createOrder({
    required String paymentMethod,
    required Map<String, dynamic> address,
    String? notes,
  }) async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) throw Exception('Not authenticated');

    final res = await dio.post(
      '/orders',
      data: {
        'paymentMethod': paymentMethod,
        'address': address,
        if (notes != null) 'notes': notes,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return res.data as Map<String, dynamic>;
  }
}
