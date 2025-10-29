import 'package:flutter/material.dart';
import 'package:flutter_foodapp/core/utils/money.dart';
import '../models/order_model.dart'; // make sure the import points to your actual OrderModel file

// 🧩 Convert status enum-like string to readable text
String _statusText(String status) {
  switch (status) {
    case 'pending':
      return 'Ожидает';
    case 'preparing':
      return 'Готовится';
    case 'ready':
      return 'Готов к выдаче';
    case 'completed':
      return 'Завершён';
    case 'cancelled':
      return 'Отменён';
    default:
      return status;
  }
}

// 🧩 Status color helper
Color _statusColor(String status) {
  switch (status) {
    case 'pending':
      return Colors.orangeAccent;
    case 'completed':
      return Colors.greenAccent;
    case 'cancelled':
      return Colors.redAccent;
    default:
      return Colors.grey;
  }
}

class OrderCard extends StatelessWidget {
  final OrderModel order;
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
            // ===== Header (Order ID + Date)
            Row(
              children: [
                Text(
                  'Заказ №${order.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '${order.createdAt.day.toString().padLeft(2, '0')}.${order.createdAt.month.toString().padLeft(2, '0')}.${order.createdAt.year}',
                  style: const TextStyle(color: Color(0xFFA7A7A7)),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // ===== Status + Payment
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle,
                          size: 8, color: _statusColor(order.status)),
                      const SizedBox(width: 6),
                      Text(
                        _statusText(order.status),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  order.paymentMethod.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ===== Address + Promo (optional)
            if (order.addressText.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.addressText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            if (order.promoCode != null && order.promoCode!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Промокод: ${order.promoCode}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),

            const SizedBox(height: 10),

            // ===== Totals section
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Сумма: ${money(order.subtotal)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Скидка: -${money(order.discount)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Доставка: ${money(order.deliveryFee)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Text(
                  money(order.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
