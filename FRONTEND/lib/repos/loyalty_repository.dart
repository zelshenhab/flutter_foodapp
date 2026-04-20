// lib/repos/loyalty_repository.dart
import '../core/api_client.dart';

class LoyaltyRepository {
  const LoyaltyRepository();

  Future<Map<String, dynamic>> getLoyaltyInfo() async {
    try {
      final res = await dio.get('/loyalty/info');
      return Map<String, dynamic>.from(res.data['data']);
    } catch (e) {
      print('Error fetching loyalty info: $e');
      return {
        'points': 0,
        'totalEarned': 0,
        'totalRedeemed': 0,
        'settings': {
          'pointsPerThousand': 50,
          'minRedeemPoints': 100,
          'maxRedeemPercent': 30,
        },
        'transactions': [],
      };
    }
  }

  Future<Map<String, dynamic>> calculatePointsRedemption({
    required double cartTotal,
    required int requestedPoints,
  }) async {
    try {
      final res = await dio.post('/loyalty/calculate', data: {
        'cartTotal': cartTotal,
        'requestedPoints': requestedPoints,
      });
      return Map<String, dynamic>.from(res.data['data']);
    } catch (e) {
      print('Error calculating points: $e');
      return {
        'availablePoints': 0,
        'requestedPoints': requestedPoints,
        'appliedPoints': 0,
        'discountAmount': 0,
        'minRedeem': 100,
        'maxRedeemPercent': 30,
        'maxPossiblePoints': 0,
      };
    }
  }

  Future<Map<String, dynamic>> redeemPoints({
    required int points,
    int? orderId,
  }) async {
    final res = await dio.post('/loyalty/redeem', data: {
      'points': points,
      'orderId': orderId,
    });
    return Map<String, dynamic>.from(res.data['data']);
  }
}