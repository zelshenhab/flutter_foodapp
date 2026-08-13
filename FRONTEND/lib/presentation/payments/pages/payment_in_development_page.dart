import 'package:flutter/material.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';

class PaymentInDevelopmentPage extends StatelessWidget {
  const PaymentInDevelopmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.onlinePayment)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction,
                  size: 64, color: Color.fromARGB(255, 236, 192, 48)),
              const SizedBox(height: 16),
              Text(
                l10n.paymentInDevTitle,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.paymentInDevBody,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFA7A7A7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
