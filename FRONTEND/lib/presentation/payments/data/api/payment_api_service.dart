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

  Future<PaymentCreateResult> createPayment(int orderId) async {
    final res = await _dio.post(
      '/payment/create',
      data: {
        'orderId': orderId,
      },
    );

    final data = Map<String, dynamic>.from(res.data as Map);

    return PaymentCreateResult(
      paymentId: (data['paymentId'] ?? '').toString(),
      confirmationUrl: (data['confirmationUrl'] ?? '').toString(),
    );
  }

  Future<String> checkPaymentStatus(String paymentId) async {
    final res = await _dio.get('/payment/status/$paymentId');
    final data = Map<String, dynamic>.from(res.data as Map);
    return (data['status'] ?? '').toString();
  }
}