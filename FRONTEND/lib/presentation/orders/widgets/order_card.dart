import 'package:flutter/material.dart';
import 'package:flutter_foodapp/core/utils/money.dart';
import '../models/order.dart';

String _statusText(OrderStatus s) {
  switch (s) {
    case OrderStatus.pending: return 'Ожидает';
    case OrderStatus.preparing: return 'Готовится';
    case OrderStatus.onTheWay: return 'В пути';
    case OrderStatus.delivered: return 'Доставлен';
    case OrderStatus.cancelled: return 'Отменён';
  }
}

class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رقم الطلب + التاريخ
            Row(
              children: [
                Text('Заказ №${order.id}',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const Spacer(),
                Text(
                  '${order.createdAt.day}.${order.createdAt.month}.${order.createdAt.year}',
                  style: const TextStyle(color: Color(0xFFA7A7A7)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // المطعم + الحالة
            Row(
              children: [
                Text(order.restaurant),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Text(_statusText(order.status),
                      style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // أول صنف + عدد إضافي
            Builder(
              builder: (_) {
                final first = order.items.first;
                final more = order.items.length - 1;
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(first.image, width: 44, height: 44, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        more > 0 ? '${first.name} и ещё $more' : first.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(money(order.grandTotal),
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
