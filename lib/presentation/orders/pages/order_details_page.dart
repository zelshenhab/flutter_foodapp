import 'package:flutter/material.dart';
import 'package:flutter_foodapp/core/utils/money.dart';
import '../models/order.dart';
import '../widgets/order_item_row.dart';

class OrderDetailsPage extends StatelessWidget {
  final OrderEntity order;
  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Заказ №${order.id}')),
      body: ListView(
        children: [
          // معلومات عامة
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.restaurant,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(
                        '${order.createdAt.day}.${order.createdAt.month}.${order.createdAt.year} • ${order.createdAt.hour.toString().padLeft(2,'0')}:${order.createdAt.minute.toString().padLeft(2,'0')}',
                        style: const TextStyle(color: Color(0xFFA7A7A7)),
                      ),
                    ],
                  ),
                ),
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
          ),

          const Divider(color: Color(0xFF2A2A2A)),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text('Состав заказа',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),

          // عناصر الطلب
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                for (final it in order.items) ...[
                  OrderItemRow(item: it),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),

          const Divider(color: Color(0xFF2A2A2A)),
          // الملخص
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                _row('Сумма заказа', money(order.itemsTotal)),
                _row('Доставка', money(order.deliveryFee)),
                if (order.discount > 0)
                  _row('Скидка', '-${money(order.discount)}'),
                const Divider(color: Color(0xFF2A2A2A)),
                _row('Итого', money(order.grandTotal), bold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String l, String v, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(l,
              style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500))),
          Text(v, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }

  String _statusText(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending: return 'Ожидает';
      case OrderStatus.preparing: return 'Готовится';
      case OrderStatus.onTheWay: return 'В пути';
      case OrderStatus.delivered: return 'Доставлен';
      case OrderStatus.cancelled: return 'Отменён';
    }
  }
}
