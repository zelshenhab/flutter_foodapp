import 'package:flutter/material.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            const Icon(Icons.credit_card,
                color: Color.fromARGB(255, 199, 160, 34)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.payOnlineCard,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const Icon(Icons.lock, size: 18, color: Color(0xFFA7A7A7)),
          ],
        ),
      ),
    );
  }
}
