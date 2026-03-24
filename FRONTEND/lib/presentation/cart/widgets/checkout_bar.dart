import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../auth/pages/login_info_page.dart';

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
        const storage = FlutterSecureStorage();
        final token = await storage.read(key: 'auth_token');

        if (token == null || token.isEmpty) {
          _showLoginRequiredDialog(context);
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

/// Small immutable view model
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

void _showLoginRequiredDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('Требуется вход'),
        content: const Text(
          'Чтобы оформить заказ, пожалуйста войдите в аккаунт.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginInfoPage(),
                ),
              );
            },
            child: const Text('Войти'),
          ),
        ],
      );
    },
  );
}