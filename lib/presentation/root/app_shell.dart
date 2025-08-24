import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../menu/pages/menu_page.dart';
import '../cart/pages/cart_page.dart';

import '../cart/bloc/cart_bloc.dart';
import '../cart/bloc/cart_state.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      MenuPage(),
      CartPage(),
      // ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // CartBloc متاح لكل الصفحات (Menu/Cart/Profile)
      create: (_) => CartBloc(),
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: _pages,
        ),
        bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
          buildWhen: (p, n) => p.items.length != n.items.length,
          builder: (context, state) {
            final cartCount = state.items.fold<int>(0, (s, x) => s + x.qty);
            return BottomNavigationBar(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_menu),
                  label: 'Menu',
                ),
                BottomNavigationBarItem(
                  // أيقونة السلة مع بادج للعدّاد
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_cart_outlined),
                      if (cartCount > 0)
                        Positioned(
                          right: -6,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$cartCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'Cart',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
