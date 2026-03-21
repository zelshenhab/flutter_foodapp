import 'package:flutter/material.dart';

class PaymentInDevelopmentPage extends StatelessWidget {
  const PaymentInDevelopmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Онлайн-оплата')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.construction, size: 64, color: Color.fromARGB(255, 236, 192, 48)),
              SizedBox(height: 16),
              Text(
                'Функция оплаты ещё в разработке',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8),
              Text(
                'Скоро мы добавим онлайн-оплату. Спасибо за понимание.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFA7A7A7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}