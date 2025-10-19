import '../core/api_client.dart';

class OrdersRepository {
  const OrdersRepository();

  Future<Map<String, dynamic>> preview() async {
    final res = await dio.post('/orders/preview', data: const {});
    return Map<String, dynamic>.from(res.data['data'] as Map);
  }

  Future<Map<String, dynamic>> createCOD(String addressText, {String? notes}) async {
    final res = await dio.post('/orders', data: {
      'paymentMethod': 'cod',
      'address': {'text': addressText},
      if (notes != null) 'notes': notes,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> list({int page = 1, int limit = 10}) async {
    final res = await dio.get('/orders', queryParameters: {'page': page, 'limit': limit});
    return Map<String, dynamic>.from(res.data as Map);
  }
}
