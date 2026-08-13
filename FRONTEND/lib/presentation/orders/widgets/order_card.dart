import 'package:flutter/material.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
import 'package:flutter_foodapp/core/utils/money.dart';
import '../models/order_model.dart';

Color _statusColor(String status) {
  switch (status) {
    case 'pending':
      return const Color.fromARGB(255, 199, 160, 34);
    case 'preparing':
      return const Color(0xFFFFB74D);
    case 'ready':
      return const Color(0xFF4CAF50);
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
    final l10n = context.l10n;

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
            Row(
              children: [
                Text(
                  l10n.orderNumber(order.id),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: _statusColor(order.status),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.statusText(order.status),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  order.paymentMethod.toUpperCase(),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 199, 160, 34),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (order.addressText.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
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
                  l10n.promoCodeLabel(order.promoCode!),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.sumLabel(money(order.subtotal)),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        l10n.discountLabel(money(order.discount)),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        l10n.serviceLabel(money(order.deliveryFee)),
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
