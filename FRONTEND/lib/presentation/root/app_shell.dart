import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../menu/pages/menu_page.dart';
import '../cart/pages/cart_page.dart';
import '../profile/pages/profile_page.dart';
import '../cart/bloc/cart_bloc.dart';
import '../cart/bloc/cart_event.dart';
import '../menu/bloc/menu_bloc.dart';
import '../menu/bloc/menu_event.dart';
import '../profile/bloc/profile_bloc.dart';
import '../profile/bloc/profile_event.dart';

class AppShell extends StatefulWidget {
  final String? initialName;
  final String? initialEmail;

  const AppShell({super.key, this.initialName, this.initialEmail});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  bool _appliedInitialProfile = false;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [MenuPage(), CartPage(), ProfilePage()];
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CartBloc()..add(const CartStarted())),
        BlocProvider(create: (_) => MenuBloc()..add(MenuStarted())),
        BlocProvider(create: (_) => ProfileBloc()..add(const ProfileStarted())),
      ],
      child: Builder(builder: (context) {
        if (!_appliedInitialProfile &&
            (widget.initialName != null && widget.initialName!.isNotEmpty)) {
          _appliedInitialProfile = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final name = widget.initialName ?? '';
            final bloc = context.read<ProfileBloc>();
            bloc
              ..add(ProfileNameChanged(name))
              ..add(const ProfileSaved());
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
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).colorScheme.primary,
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
      }),
    );
  }
}
