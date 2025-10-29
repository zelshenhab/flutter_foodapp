import 'package:flutter_foodapp/presentation/orders/models/order_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class OrdersRepository {
  const OrdersRepository();

  static const _storage = FlutterSecureStorage();
  static const _baseUrl = 'http://10.0.2.2:4000/api'; // replace with your backend URL

  Future<List<OrderModel>> getUserOrders() async {
    // 🔐 Get token from storage
    final token = await _storage.read(key: 'auth_token');
    if (token == null) throw Exception('Not authenticated');

    final dio = Dio(BaseOptions(headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    }));

    final response = await dio.get('$_baseUrl/orders');
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch orders');
    }

    final data = response.data['data'] ?? response.data['orders'] ?? response.data;

    return (data as List)
        .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<OrderModel> getOrderDetail(int id) async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) throw Exception('Not authenticated');

    final dio = Dio(BaseOptions(headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    }));

    final response = await dio.get('$_baseUrl/orders/$id');
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch order detail');
    }

    final data = response.data['data'];
    return OrderModel.fromJson(Map<String, dynamic>.from(data));
  }
}
