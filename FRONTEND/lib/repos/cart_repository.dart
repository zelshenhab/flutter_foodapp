import '../core/api_client.dart';

class CartRepository {
  const CartRepository();

  /// GET /cart  ->  { data: {...} }
  Future<Map<String, dynamic>> getCart() async {
    final res = await dio.get('/cart');
    return Map<String, dynamic>.from(res.data['data'] as Map);
  }

  Future<int> addItem({
    required int itemId,
    int quantity = 1,
    List<int>? optionIds,
  }) async {
    final res = await dio.post('/cart/items', data: {
      'itemId': itemId,
      'quantity': quantity,
      'optionIds': optionIds ?? [],
    });
    return (res.data['id'] as num).toInt();
  }

  /// PATCH /cart/items  (absolute quantity)
  /// Body: { itemId, quantity }
  Future<void> updateQuantity({
    required int itemId,
    required int quantity,
  }) async {
    await dio.patch('/cart/items', data: {
      'itemId': itemId,
      'quantity': quantity,
    });
  }

  /// DELETE /cart/items/:itemId
  Future<void> removeItem({required int itemId}) async {
    await dio.delete('/cart/items/$itemId');
  }

  /// POST /cart/apply-promo  -> { data: {...} }
  /// Send empty string to clear the promo
  Future<Map<String, dynamic>> applyPromo(String code) async {
    final res = await dio.post('/cart/apply-promo', data: {'code': code});
    return Map<String, dynamic>.from(res.data['data'] as Map);
  }
  
  Future<Map<String, dynamic>> applyPoints(int points) async {
    final res = await dio.post('/cart/apply-points', data: {'points': points});
    return Map<String, dynamic>.from(res.data['data']);
  }
  
  Future<Map<String, dynamic>> removePoints() async {
    final res = await dio.delete('/cart/remove-points');
    return Map<String, dynamic>.from(res.data['data']);
  }
}

