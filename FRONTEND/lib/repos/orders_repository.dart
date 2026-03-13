import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_foodapp/presentation/orders/models/order_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OrdersRepository {
  const OrdersRepository();

  static const _storage = FlutterSecureStorage();
  static const _baseUrl = 'https://adam-eve-ebon.vercel.app/api';

  Dio _createDio(String token) {
    return Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json, // ✅ prefer JSON decoding
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  dynamic _normalizeBody(dynamic body) {
    // ✅ Some servers return JSON as a string -> decode manually
    if (body is String) {
      return jsonDecode(body);
    }
    return body;
  }

  List<dynamic> _extractList(dynamic body) {
    body = _normalizeBody(body);

    // ✅ Your backend for GET /orders returns: [ ... ]
    if (body is List) return body;

    // ✅ But also support wrapped shapes: { data: [...] } or { orders: [...] }
    if (body is Map<String, dynamic>) {
      final list = body['data'] ?? body['orders'];
      if (list is List) return list;
    }

    throw FormatException('Invalid orders format: ${body.runtimeType}');
  }

  Map<String, dynamic> _extractMap(dynamic body) {
    body = _normalizeBody(body);

    // ✅ Your backend for GET /orders/:id returns: { data: {...} }
    if (body is Map<String, dynamic>) {
      final data = body['data'] ?? body;
      if (data is Map<String, dynamic>) return data;
    }

    throw FormatException('Invalid order detail format: ${body.runtimeType}');
  }

  /// 🔹 Get all orders for current user
  Future<List<OrderModel>> getUserOrders() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }

    final dio = _createDio(token);
    final response = await dio.get('/orders');

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch orders (status: ${response.statusCode})');
    }

    final list = _extractList(response.data);

    return list
        .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// 🔹 Get single order detail
  Future<OrderModel> getOrderDetail(int id) async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }

    final dio = _createDio(token);
    final response = await dio.get('/orders/$id');

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to fetch order detail (status: ${response.statusCode})');
    }

    final map = _extractMap(response.data);
    return OrderModel.fromJson(map);
  }

  /// 🔹 Confirm pickup (mark order as completed)
  Future<void> confirmPickup(int orderId) async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }

    final dio = _createDio(token);
    final response = await dio.put('/orders/$orderId/complete');

    // backend returns 200 with json {data} (in your controller)
    // but we accept 200/204 to be safe
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Failed to confirm pickup (status: ${response.statusCode})');
    }
  }
}