import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/utils/money.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_state.dart';

class SummaryPanel extends StatelessWidget {
  final bool pickup; // ✅ نحدّد إن ده ملخص Pickup
  final String? pickupAddress;

  const SummaryPanel({super.key, this.pickup = false, this.pickupAddress});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      buildWhen: (p, n) =>
          p.subtotal != n.subtotal ||
          p.discount != n.discount ||
          p.total != n.total ||
          p.promoCode != n.promoCode,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              if (pickup && pickupAddress != null) ...[
                _infoChip('Самовывоз — $pickupAddress'),
                const SizedBox(height: 8),
              ],

              _row('Сумма заказа', money(state.itemsTotal)),
              if (state.discount > 0)
                _row('Скидка', '-${money(state.discount)}'),

              const Divider(color: Color(0xFF2A2A2A)),
              _row('Итого', money(state.grandTotal), bold: true),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String l, String v, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(l, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500))),
          Text(v, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _infoChip(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
