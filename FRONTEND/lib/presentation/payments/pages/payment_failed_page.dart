// lib/presentation/payments/pages/payment_failed_page.dart
import 'package:flutter/material.dart';

class PaymentFailedPage extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onGoToCart;
  final String? reason;

  const PaymentFailedPage({
    super.key,
    this.onRetry,
    this.onGoToCart,
    this.reason,
  });

  @override
  Widget build(BuildContext context) {
    const text = Color(0xFFEDEDED);
    const hint = Color(0xFFA7A7A7);

    return Scaffold(
      appBar: AppBar(title: const Text('Оплата')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(.15),
                ),
                child: const Icon(Icons.close_rounded,
                    size: 42, color: Colors.redAccent),
              ),
              const SizedBox(height: 16),
              const Text(
                'Оплата не прошла',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reason ?? 'Проверьте карту или попробуйте ещё раз.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: hint),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onRetry ?? () => Navigator.pop(context),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Попробовать снова'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed:
                      onGoToCart ?? () => Navigator.popUntil(context, (r) => r.isFirst),
                  child: const Text('Вернуться в корзину'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
