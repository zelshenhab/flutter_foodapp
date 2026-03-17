import 'package:dio/dio.dart';

class PaymentApiService {
  final Dio _dio;

  PaymentApiService(this._dio);

  /// Create YooKassa payment
  /// POST /api/payment/create
  Future<String> createPayment(int orderId) async {
    final res = await _dio.post(
      '/payment/create',
      data: {
        'orderId': orderId,
      },
    );

    return res.data['confirmationUrl'];
  }
}