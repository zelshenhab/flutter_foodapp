import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
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
  bool _enabled = false;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final has = _ctrl.text.trim().isNotEmpty;
      if (has != _enabled) setState(() => _enabled = has);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _apply() async {
    final code = _ctrl.text.trim();
    if (code.isEmpty) return;

    setState(() => _isApplying = true);

    // Clear previous error
    context.read<CartBloc>().add(CartPromoApplied(code));

    // Wait a bit for the bloc to process
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() => _isApplying = false);

    // Clear the input field after applying
    _ctrl.clear();
    setState(() => _enabled = false);

    // Close keyboard
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const borderColor = Color(0xFF2A2A2A);
    const fieldBg = Color(0xFF1E1E1E);

    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      enabled: !_isApplying,
                      style: const TextStyle(color: Color(0xFFEDEDED)),
                      decoration: InputDecoration(
                        hintText: l10n.enterPromo,
                        hintStyle: const TextStyle(color: Color(0xFFA7A7A7)),
                        filled: true,
                        fillColor: fieldBg,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _enabled && !_isApplying ? _apply : null,
                      child: _isApplying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.apply),
                    ),
                  ),
                ],
              ),
            ),
            // Show promo status messages
            if (state.promoError != null && state.promoCode == null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.promoError!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (state.hasValidPromo)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.promoApplied(
                            state.promoCode!,
                            state.discount.toStringAsFixed(0),
                          ),
                          style: const TextStyle(
                              color: Colors.green, fontSize: 12),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context
                              .read<CartBloc>()
                              .add(const CartPromoApplied(''));
                        },
                        child: const Icon(Icons.close,
                            color: Colors.green, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
