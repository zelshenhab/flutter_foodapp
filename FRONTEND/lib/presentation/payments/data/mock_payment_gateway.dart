// lib/presentation/payments/data/mock_payment_gateway.dart
import 'dart:math';
import 'dart:async';

class MockPaymentGateway {
  static Future<String> createPaymentIntent({
    required double amount,
    required String currency,
    required String description,
  }) async {
    // محاكاة تأخير شبكة
    await Future.delayed(const Duration(milliseconds: 600));
    return 'pi_${DateTime.now().millisecondsSinceEpoch}';
  }

  static Future<bool> confirm(String intentId) async {
    await Future.delayed(const Duration(milliseconds: 900));
    // نجح 80% - للتجربة
    return Random().nextInt(10) < 8;
  }
}
