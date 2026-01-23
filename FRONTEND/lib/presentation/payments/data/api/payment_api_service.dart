import 'package:dio/dio.dart';

class PaymentApiService {
  final Dio _dio;
  PaymentApiService(this._dio);

  /// POST /api/payment/confirm
  Future<void> confirmPayment(int orderId) async {
    await _dio.post(
      '/api/payment/confirm',
      data: {'orderId': orderId},
    );
  }
}
