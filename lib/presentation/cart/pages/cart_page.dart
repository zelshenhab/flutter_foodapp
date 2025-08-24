import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../widgets/restaurant_header.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/address_box.dart';
import '../widgets/summary_panel.dart';
import '../widgets/checkout_bar.dart';
import '../widgets/promo_field.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Корзина')),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 48,
                    color: Color(0xFFA7A7A7),
                  ),
                  SizedBox(height: 8),
                  Text('Корзина пуста'),
                ],
              ),
            );
          }

          return ListView(
            children: [
              const RestaurantHeader(showName: true),

              // العناصر مع السحب للحذف + SnackBar Undo
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
                            color: Colors.red.withOpacity(.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          context.read<CartBloc>().add(
                            CartItemRemoved(ci.item.id),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Удалено: ${ci.item.name}'),
                              action: SnackBarAction(
                                label: 'Отменить',
                                onPressed: () {
                                  // إرجاع العنصر واحد كمية 1 (أبسط سلوك)
                                  context.read<CartBloc>().add(
                                    CartItemAdded(ci.item),
                                  );
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

              // حقل البروموكود
              const PromoField(),

              // Chip يظهر عند تفعيل الخصم لإزالته
              if (state.promoCode != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ActionChip(
                      avatar: const Icon(Icons.percent, size: 18),
                      label: Text('Промокод: ${state.promoCode}'),
                      onPressed: () => context.read<CartBloc>().add(
                        const CartPromoApplied(''),
                      ),
                    ),
                  ),
                ),

              const PaymentMethodSelector(),
              const AddressBox(),
              const SummaryPanel(),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
      bottomNavigationBar: CheckoutBar(
        onCheckout: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Переход к оформлению заказа')),
          );
        },
      ),
    );
  }
}
