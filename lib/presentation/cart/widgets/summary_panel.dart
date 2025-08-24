import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_state.dart';
import '../bloc/cart_bloc.dart';

class SummaryPanel extends StatelessWidget {
  const SummaryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        Widget row(String label, String value, {bool bold = false}) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                Expanded(child: Text(label,
                    style: TextStyle(
                      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                    ))),
                Text(value,
                    style: TextStyle(
                      fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                    )),
              ],
            ),
          );
        }

        final discount = state.discount;
        final hasDiscount = discount > 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              row('Сумма заказа', '${state.itemsTotal.toStringAsFixed(0)} ₽'),
              row('Доставка', '${state.deliveryFee.toStringAsFixed(0)} ₽'),
              if (hasDiscount)
                row(
                  'Скидка${state.promoCode != null ? ' (${state.promoCode})' : ''}',
                  '-${discount.toStringAsFixed(0)} ₽',
                ),
              const Divider(color: Color(0xFF2A2A2A)),
              row('Итого', '${state.grandTotal.toStringAsFixed(0)} ₽', bold: true),
            ],
          ),
        );
      },
    );
  }
}
