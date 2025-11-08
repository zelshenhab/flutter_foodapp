import 'package:flutter/material.dart';
import 'package:flutter_foodapp/core/utils/money.dart';
import '../models/order_item.dart';

class OrderItemRow extends StatelessWidget {
  final OrderItem item;
  const OrderItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 🖼️ Image (optional fallback)
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: (item.image != null && item.image!.isNotEmpty)
              ? Image.network(
                  item.image!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),

        const SizedBox(width: 10),

        // 🧾 Item title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (item.options != null && item.options!.isNotEmpty)
                Text(
                  item.options!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFA7A7A7),
                  ),
                ),
            ],
          ),
        ),

        // 💰 Quantity × Price
        Text(
          '× ${item.quantity}  ·  ${money(item.lineTotal)}',
          style: const TextStyle(
            color: Color(0xFFA7A7A7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _placeholder() => Container(
        width: 40,
        height: 40,
        color: const Color(0xFF2A2A2A),
        child: const Icon(Icons.fastfood, size: 20, color: Color(0xFFA7A7A7)),
      );
}
