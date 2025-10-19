import 'package:flutter/material.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({super.key});

  @override
  Widget build(BuildContext context) {
    // عرض معلومات فقط — الدفع الأونلاين هو الخيار الوحيد
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
          children: const [
            Icon(Icons.credit_card, color: Color(0xFFFF7A00)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Оплата онлайн (банковская карта)',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Icon(Icons.lock, size: 18, color: Color(0xFFA7A7A7)),
          ],
        ),
      ),
    );
  }
}
