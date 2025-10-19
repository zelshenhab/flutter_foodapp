// lib/presentation/payments/pages/payment_history_page.dart
import 'package:flutter/material.dart';

enum PaymentStatus { success, failed, pending }

class PaymentRecord {
  final String id;
  final DateTime createdAt;
  final double amount;
  final PaymentStatus status;
  final String method;
  final String? orderId;

  PaymentRecord({
    required this.id,
    required this.createdAt,
    required this.amount,
    required this.status,
    required this.method,
    this.orderId,
  });
}

class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = _mockPayments();

    return Scaffold(
      appBar: AppBar(title: const Text('История оплат')),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: data.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (_, i) => _PaymentTile(p: data[i]),
      ),
    );
  }

  List<PaymentRecord> _mockPayments() {
    final now = DateTime.now();
    return [
      PaymentRecord(
        id: 'PAY-2025-000127',
        createdAt: now.subtract(const Duration(hours: 3)),
        amount: 949,
        status: PaymentStatus.success,
        method: 'Онлайн · **** 1234',
        orderId: '1042',
      ),
      PaymentRecord(
        id: 'PAY-2025-000119',
        createdAt: now.subtract(const Duration(days: 2, hours: 4)),
        amount: 520,
        status: PaymentStatus.failed,
        method: 'Онлайн · **** 1234',
        orderId: '1031',
      ),
      PaymentRecord(
        id: 'PAY-2025-000101',
        createdAt: now.subtract(const Duration(days: 6)),
        amount: 1299,
        status: PaymentStatus.success,
        method: 'Онлайн · **** 1234',
        orderId: '1019',
      ),
    ];
  }
}

class _PaymentTile extends StatelessWidget {
  final PaymentRecord p;
  const _PaymentTile({required this.p});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${p.createdAt.day.toString().padLeft(2, '0')}.${p.createdAt.month.toString().padLeft(2, '0')}.${p.createdAt.year} '
        '• ${p.createdAt.hour.toString().padLeft(2, '0')}:${p.createdAt.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    p.id,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                _statusChip(p.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(dateStr, style: const TextStyle(color: Color(0xFFA7A7A7))),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text(p.method)),
                Text(
                  '${p.amount.toStringAsFixed(0)} ₽',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            if (p.orderId != null) ...[
              const SizedBox(height: 6),
              Text(
                'Заказ №${p.orderId}',
                style: const TextStyle(color: Color(0xFFA7A7A7)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusChip(PaymentStatus s) {
    late final Color c;
    late final String text;
    switch (s) {
      case PaymentStatus.success:
        c = Colors.greenAccent.withOpacity(.15);
        text = 'Успешно';
        break;
      case PaymentStatus.failed:
        c = Colors.redAccent.withOpacity(.15);
        text = 'Ошибка';
        break;
      case PaymentStatus.pending:
        c = Colors.orangeAccent.withOpacity(.15);
        text = 'Ожидает';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
