import 'package:flutter/material.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';

class PaymentFailedPage extends StatelessWidget {
  final String? reason;

  const PaymentFailedPage({
    super.key,
    this.reason,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const text = Color(0xFFEDEDED);
    const hint = Color(0xFFA7A7A7);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentError)),
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
                  color: Colors.red.withValues(alpha: .12),
                ),
                child: const Icon(Icons.error_outline,
                    size: 42, color: Colors.redAccent),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.paymentDeclined,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reason ?? l10n.tryAgain,
                textAlign: TextAlign.center,
                style: const TextStyle(color: hint),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.goBack),
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
