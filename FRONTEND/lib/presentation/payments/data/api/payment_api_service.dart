import 'package:dio/dio.dart';

class PaymentCreateResult {
  final String paymentId;
  final String confirmationUrl;

  const PaymentCreateResult({
    required this.paymentId,
    required this.confirmationUrl,
  });
}

class PaymentApiService {
  final Dio _dio;

  PaymentApiService(this._dio);

  /// POST /api/payment/create
  Future<PaymentCreateResult> createPayment(int orderId) async {
    final res = await _dio.post(
      '/payment/create',
      data: {
        'orderId': orderId,
      },
    );

    final data = res.data as Map<String, dynamic>;

    return PaymentCreateResult(
      paymentId: (data['paymentId'] ?? '').toString(),
      confirmationUrl: (data['confirmationUrl'] ?? '').toString(),
    );
  }
}