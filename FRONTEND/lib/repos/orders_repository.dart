import 'package:flutter_foodapp/presentation/orders/models/order_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class OrdersRepository {
  const OrdersRepository();

  static const _storage = FlutterSecureStorage();
  static const _baseUrl = 'http://10.0.2.2:4000/api'; // ⚙️ Replace with backend URL if needed

  Dio _createDio(String token) {
    return Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  /// 🔹 Get all orders for current user
  Future<List<OrderModel>> getUserOrders() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) throw Exception('Not authenticated');

    final dio = _createDio(token);
    final response = await dio.get('/orders');

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch orders');
    }

    final data = response.data['data'] ?? response.data['orders'] ?? response.data;
    if (data is! List) throw Exception('Invalid orders format');

    return data
        .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e)))
        .toList()
        .cast<OrderModel>();
  }

  /// 🔹 Get single order detail
  Future<OrderModel> getOrderDetail(int id) async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) throw Exception('Not authenticated');

    final dio = _createDio(token);
    final response = await dio.get('/orders/$id');

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch order detail');
    }

    final data = response.data['data'] ?? response.data;
    return OrderModel.fromJson(Map<String, dynamic>.from(data));
  }

  /// 🔹 Confirm pickup (mark order as completed)
  Future<void> confirmPickup(int orderId) async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) throw Exception('Not authenticated');

    final dio = _createDio(token);
    try {
      final response = await dio.put('/orders/$orderId/complete');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to confirm pickup');
      }
    } catch (e) {
      // optional: log or rethrow
      rethrow;
    }
  }
}
