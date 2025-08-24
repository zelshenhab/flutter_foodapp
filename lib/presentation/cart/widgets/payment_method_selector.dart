import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../models/payment_method.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      buildWhen: (p, n) => p.paymentMethod != n.paymentMethod,
      builder: (context, state) {
        Widget tile(PaymentMethod method, IconData icon, String title) {
          final selected = state.paymentMethod == method;
          return InkWell(
            onTap: () => context.read<CartBloc>()
                .add(CartPaymentMethodChanged(method)),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : const Color(0xFF2A2A2A),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: selected
                      ? Theme.of(context).colorScheme.primary
                      : const Color(0xFFA7A7A7)),
                  const SizedBox(width: 10),
                  Text(title),
                  const Spacer(),
                  Icon(
                    selected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : const Color(0xFFA7A7A7),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text('Способ оплаты',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  tile(PaymentMethod.card, Icons.credit_card, 'Банковская карта'),
                  const SizedBox(height: 8),
                  tile(PaymentMethod.cash, Icons.payments_outlined, 'Наличными'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
