import 'package:flutter/material.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
import 'package:flutter_foodapp/core/utils/money.dart';
import '../models/order_history.dart';

class OrderHistoryTile extends StatelessWidget {
  final OrderHistory order;
  const OrderHistoryTile({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final itemsText = order.items.join(", ");
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: const Icon(Icons.receipt_long,
          color: Color.fromARGB(255, 199, 160, 34)),
      title: Text("${l10n.orderNumber(order.id)} — ${order.restaurant}",
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        "${order.date.day}.${order.date.month}.${order.date.year} · $itemsText",
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(money(order.total),
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
