import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/auth/auth_session.dart';
import 'package:flutter_foodapp/core/branches/branch_cubit.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
import 'package:flutter_foodapp/presentation/common/widgets/app_toast.dart';
import 'package:flutter_foodapp/presentation/common/widgets/login_required_dialog.dart';
import 'package:flutter_foodapp/presentation/cart/widgets/loyalty_card.dart';
import 'package:flutter_foodapp/presentation/common/widgets/branch_selector.dart';
import 'package:flutter_foodapp/presentation/payments/pages/online_payment_page.dart';

import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';

import '../widgets/restaurant_header.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/summary_panel.dart';
import '../widgets/checkout_bar.dart';
import '../widgets/promo_field.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      context.read<CartBloc>().add(const CartStarted());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const _CartScaffold();
  }
}

class _CartScaffold extends StatelessWidget {
  const _CartScaffold();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final branch = context.watch<BranchCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cart)),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.isEmpty) {
            return const _EmptyCartBody();
          }

          return ListView(
            children: [
              RestaurantHeader(
                showName: true,
                showPickupBadge: true,
                pickupAddress: branch.fullAddress,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: BranchSelectorTile(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    for (final ci in state.items)
                      Dismissible(
                        key: ValueKey(ci.item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 206, 44),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          context
                              .read<CartBloc>()
                              .add(CartItemRemoved(ci.item.id));
                          AppToast.info(context, l10n.removedItem(ci.item.name));
                        },
                        child: CartItemTile(cartItem: ci),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const PromoField(),
              const LoyaltyCard(),
              const PaymentMethodSelector(),
              SummaryPanel(
                pickup: true,
                pickupAddress: branch.fullAddress,
              ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
      bottomNavigationBar: CheckoutBar(
        onCheckout: () {
          final state = context.read<CartBloc>().state;
          final amount = state.grandTotal;
          final selected = context.read<BranchCubit>().state;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CartBloc>(),
                child: OnlinePaymentPage(
                  amount: amount,
                  description: context.l10n.cartCheckoutDescription,
                  addressText: selected.fullAddress,
                  branchId: selected.id,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyCartBody extends StatefulWidget {
  const _EmptyCartBody();

  @override
  State<_EmptyCartBody> createState() => _EmptyCartBodyState();
}

class _EmptyCartBodyState extends State<_EmptyCartBody> {
  bool? _isGuest;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final loggedIn = await AuthSession.isLoggedIn();
    if (!mounted) return;
    setState(() => _isGuest = !loggedIn);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_isGuest == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isGuest == true) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: Color(0xFFA7A7A7),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.guestCartHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFEDEDED),
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => showLoginRequiredDialog(
                context,
                message: l10n.loginRequiredAddToCart,
              ),
              child: Text(l10n.signIn),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_cart_outlined,
              size: 48, color: Color(0xFFA7A7A7)),
          const SizedBox(height: 8),
          Text(l10n.cartEmpty),
        ],
      ),
    );
  }
}
