import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_state.dart';

class CheckoutBar extends StatelessWidget {
  final VoidCallback onCheckout;
  const CheckoutBar({super.key, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final disabled = state.isEmpty;
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Итого: ${state.grandTotal.toStringAsFixed(0)} ₽',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: disabled ? null : onCheckout,
                    child: const Text('Оформить заказ'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
