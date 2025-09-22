import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/utils/money.dart';
import '../bloc/cart_state.dart';
import '../bloc/cart_bloc.dart';

const _minOrder = 500.0; // حد أدنى تجريبي

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

        final hasDiscount = state.discount > 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              row('Сумма заказа', money(state.itemsTotal)),
              row('Доставка', money(state.deliveryFee)),
              if (hasDiscount)
                row('Скидка${state.promoCode != null ? ' (${state.promoCode})' : ''}',
                    '-${money(state.discount)}'),
              const Divider(color: Color(0xFF2A2A2A)),
              row('Итого', money(state.grandTotal), bold: true),

              if (state.itemsTotal < _minOrder)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Text(
                    'Минимальная сумма заказа ${money(_minOrder)}',
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
