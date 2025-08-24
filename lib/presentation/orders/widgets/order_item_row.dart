import 'package:flutter/material.dart';
import 'package:flutter_foodapp/core/utils/money.dart';
import '../models/order.dart';

class OrderItemRow extends StatelessWidget {
  final OrderItem item;
  const OrderItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(item.image, width: 40, height: 40, fit: BoxFit.cover),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Text('× ${item.qty}  ·  ${money(item.subtotal)}',
            style: const TextStyle(color: Color(0xFFA7A7A7))),
      ],
    );
  }
}
