import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../menu/pages/menu_page.dart';
import '../cart/pages/cart_page.dart';
import '../profile/pages/profile_page.dart';

import '../cart/bloc/cart_bloc.dart';
import '../menu/bloc/menu_bloc.dart';
import '../menu/bloc/menu_event.dart';
import '../profile/bloc/profile_bloc.dart';
import '../profile/bloc/profile_event.dart';

class AppShell extends StatefulWidget {
  final String? initialName;
  final String? initialPhone;

  const AppShell({super.key, this.initialName, this.initialPhone});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  late final List<Widget> _pages;
  bool _dispatchedInitialProfile = false;

  @override
  void initState() {
    super.initState();
    _pages = [const MenuPage(), CartPage(), const ProfilePage()];
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CartBloc>(create: (_) => CartBloc()),
        BlocProvider<MenuBloc>(create: (_) => MenuBloc()..add(MenuStarted())),
        BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc()..add(ProfileStarted()),
        ),
      ],
      child: Builder(
        builder: (context) {
          // بعد أول فريم: لو فيه بيانات جاية من الـ OTP ولم نرسلها بعد → حدّث البروفايل
          if (!_dispatchedInitialProfile &&
              (widget.initialName != null || widget.initialPhone != null)) {
            _dispatchedInitialProfile = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final name = widget.initialName;
              final phone = widget.initialPhone;
              if (name != null || phone != null) {
                context.read<ProfileBloc>().add(
                  ProfileInfoUpdated(name: name ?? '', phone: phone ?? ''),
                );
              }
            });
          }

          return Scaffold(
            body: IndexedStack(index: _index, children: _pages),

            bottomNavigationBar: Builder(
              builder: (context) {
                final cartCount = context.select<CartBloc, int>(
                  (b) => b.state.items.fold<int>(0, (s, x) => s + x.qty),
                );
                return BottomNavigationBar(
                  currentIndex: _index,
                  onTap: (i) => setState(() => _index = i),
                  items: [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.restaurant_menu),
                      label: 'Menu',
                    ),
                    BottomNavigationBarItem(
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.shopping_cart_outlined),
                          if (cartCount > 0)
                            Positioned(
                              right: -6,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
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
          );
        },
      ),
    );
  }
}
