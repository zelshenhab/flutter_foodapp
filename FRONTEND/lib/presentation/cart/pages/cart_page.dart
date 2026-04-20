import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/presentation/cart/widgets/loyalty_card.dart';
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
    // Dispatch once if you DON'T already dispatch CartStarted at app root.
    if (!_started) {
      _started = true;
      context.read<CartBloc>().add(const CartStarted());
    }
  }

  @override
  Widget build(BuildContext context) {
    // If your CartBloc is provided at app root, this is enough:
    return const _CartScaffold();

    // If you DON'T provide CartBloc above, wrap with a local provider instead:
    // return BlocProvider<CartBloc>(
    //   create: (_) => CartBloc()..add(const CartStarted()),
    //   child: const _CartScaffold(),
    // );
  }
}

class _CartScaffold extends StatelessWidget {
  const _CartScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Корзина')),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 48, color: Color(0xFFA7A7A7)),
                  SizedBox(height: 8),
                  Text('Корзина пуста'),
                ],
              ),
            );
          }

          return ListView(
            children: [
              const RestaurantHeader(
                showName: true,
                showPickupBadge: true,
                pickupAddress: 'ул. Пушкина 15',
              ),

              // Use the BlocBuilder's reactive state here 👇
              // inside BlocBuilder<CartBloc, CartState> builder:
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    for (final ci in state.items)  // <— use state.items
                      Dismissible(
                        key: ValueKey(ci.item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 206, 44),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          context.read<CartBloc>().add(CartItemRemoved(ci.item.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Удалено: ${ci.item.name}'),
                              action: SnackBarAction(
                                label: 'Отменить',
                                onPressed: () {
                                  context.read<CartBloc>().add(CartItemAdded(ci.item));
                                },
                              ),
                            ),
                          );
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
              const SummaryPanel(pickup: true, pickupAddress: 'ул. Пушкина 15'),

              const SizedBox(height: 80),
            ],
          );
        },
      ),
      bottomNavigationBar: CheckoutBar(
        onCheckout: () {
          final state = context.read<CartBloc>().state;
          final amount = state.grandTotal;
          Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<CartBloc>(), // 🔥 PASS SAME INSTANCE
              child: OnlinePaymentPage(
                amount: amount,
                description: 'Самовывоз: заказ из корзины',
              ),
            ),
          ),
        );
        },
      ),
    );
  }
}
