import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/utils/money.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../models/cart_item.dart';

class CartItemTile extends StatelessWidget {
  final CartItem cartItem;
  const CartItemTile({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final item = cartItem.item;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(item.image, width: 56, height: 56, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('${money(item.price)} × ${cartItem.qty}',
                    style: const TextStyle(color: Color(0xFFA7A7A7), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              _qtyBtn(
                icon: Icons.remove,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.read<CartBloc>().add(CartItemQtyDecreased(item.id));
                },
                bg: const Color(0xFF1E1E1E),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('${cartItem.qty}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              _qtyBtn(
                icon: Icons.add,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.read<CartBloc>().add(CartItemQtyIncreased(item.id));
                },
                bg: accent,
                iconColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(money(cartItem.subtotal),
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              IconButton(
                tooltip: "Удалить",
                onPressed: () => context.read<CartBloc>().add(CartItemRemoved(item.id)),
                icon: const Icon(Icons.delete_outline, color: Color(0xFFA7A7A7)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color bg = const Color(0xFFFF7A00),
    Color iconColor = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}
