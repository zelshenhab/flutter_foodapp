import '../core/api_client.dart';

class CartRepository {
  const CartRepository();

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
    // backend returns { id: <int> }
    return (res.data['id'] as num).toInt();
  }

  Future<Map<String, dynamic>> applyPromo(String code) async {
    final res = await dio.post('/cart/apply-promo', data: {'code': code});
    return Map<String, dynamic>.from(res.data['data'] as Map);
  }
}
