import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/presentation/cart/bloc/cart_bloc.dart';
import 'package:flutter_foodapp/presentation/cart/widgets/promo_field.dart';
import '../bloc/cart_state.dart';
import '../widgets/restaurant_header.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/address_box.dart';
import '../widgets/summary_panel.dart';
import '../widgets/checkout_bar.dart';

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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    for (final ci in state.items) CartItemTile(cartItem: ci),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const PromoField(),
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
