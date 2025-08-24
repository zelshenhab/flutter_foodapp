import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';

class PromoField extends StatefulWidget {
  const PromoField({super.key});

  @override
  State<PromoField> createState() => _PromoFieldState();
}

class _PromoFieldState extends State<PromoField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF2A2A2A);
    const fieldBg = Color(0xFF1E1E1E);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              style: const TextStyle(color: Color(0xFFEDEDED)),
              decoration: InputDecoration(
                hintText: 'Введите промокод',
                hintStyle: const TextStyle(color: Color(0xFFA7A7A7)),
                filled: true,
                fillColor: fieldBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                final code = _ctrl.text.trim();
                if (code.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Введите промокод')),
                  );
                  return;
                }
                context.read<CartBloc>().add(CartPromoApplied(code));
                FocusScope.of(context).unfocus();
              },
              child: const Text('Применить'),
            ),
          ),
        ],
      ),
    );
  }
}
