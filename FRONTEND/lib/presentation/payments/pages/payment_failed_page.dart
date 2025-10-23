// lib/presentation/payments/pages/payment_failed_page.dart
import 'package:flutter/material.dart';

class PaymentFailedPage extends StatelessWidget {
  final String? reason;

  const PaymentFailedPage({
    super.key,
    this.reason,
  });

  @override
  Widget build(BuildContext context) {
    const text = Color(0xFFEDEDED);
    const hint = Color(0xFFA7A7A7);

    return Scaffold(
      appBar: AppBar(title: const Text('Ошибка оплаты')),
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
                  color: Colors.red.withOpacity(.12),
                ),
                child: const Icon(Icons.error_outline,
                    size: 42, color: Colors.redAccent),
              ),
              const SizedBox(height: 16),
              const Text(
                'Оплата отклонена',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reason ?? 'Попробуйте ещё раз',
                textAlign: TextAlign.center,
                style: const TextStyle(color: hint),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Вернуться'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
