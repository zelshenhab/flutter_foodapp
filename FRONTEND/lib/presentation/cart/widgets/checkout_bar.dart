import 'package:flutter/material.dart';

class CheckoutBar extends StatelessWidget {
  final VoidCallback onCheckout;
  final bool pickup;

  const CheckoutBar({super.key, required this.onCheckout, this.pickup = false});

  @override
  Widget build(BuildContext context) {
    final label = pickup ? 'Оформить самовывоз' : 'Оформить заказ';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(onPressed: onCheckout, child: Text(label)),
      ),
    );
  }
}
