// lib/presentation/payments/pages/payment_success_page.dart
import 'package:flutter/material.dart';

class PaymentSuccessPage extends StatelessWidget {
  final String orderId;
  final double amount;

  const PaymentSuccessPage({
    super.key,
    required this.orderId,
    required this.amount,
  });

  String _money(double v) => '${v.toStringAsFixed(0)} ₽';

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
                  color: Colors.green.withOpacity(.15),
                ),
                child: const Icon(Icons.check_rounded,
                    size: 42, color: Colors.greenAccent),
              ),
              const SizedBox(height: 16),
              const Text(
                'Оплата прошла успешно',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Заказ №$orderId оформлен.\nСумма: ${_money(amount)}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: hint),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // ارجع لأول شاشة (مثلاً المنيو) — عدل على حسب هيكل الروت عندك
                    Navigator.popUntil(context, (r) => r.isFirst);
                  },
                  child: const Text('Готово'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
