import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/auth/auth_session.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
import 'package:flutter_foodapp/presentation/common/widgets/login_required_dialog.dart';

import '../bloc/cart_bloc.dart';
import '../bloc/cart_state.dart';

class CheckoutBar extends StatelessWidget {
  final VoidCallback onCheckout;
  final bool pickup;

  const CheckoutBar({
    super.key,
    required this.onCheckout,
    this.pickup = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = pickup ? l10n.checkoutPickup : l10n.checkoutOrder;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: BlocSelector<CartBloc, CartState, _CheckoutViewModel>(
          selector: (state) => _CheckoutViewModel(
            isEmpty: state.items.isEmpty,
            isLoading: state.loading,
          ),
          builder: (context, vm) {
            return ElevatedButton(
              onPressed: (vm.isEmpty || vm.isLoading)
                  ? null
                  : () async {
                      if (!await AuthSession.isLoggedIn()) {
                        if (!context.mounted) return;
                        await showLoginRequiredDialog(
                          context,
                          message: context.l10n.loginRequiredCheckout,
                        );
                        return;
                      }

                      onCheckout();
                    },
              child: vm.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(label),
            );
          },
        ),
      ),
    );
  }
}

class _CheckoutViewModel {
  final bool isEmpty;
  final bool isLoading;

  const _CheckoutViewModel({
    required this.isEmpty,
    required this.isLoading,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CheckoutViewModel &&
          isEmpty == other.isEmpty &&
          isLoading == other.isLoading;

  @override
  int get hashCode => Object.hash(isEmpty, isLoading);
}
