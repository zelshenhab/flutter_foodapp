import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../menu/pages/menu_page.dart';
import '../cart/pages/cart_page.dart';
import '../profile/pages/profile_page.dart';

import '../cart/bloc/cart_bloc.dart';
import '../cart/bloc/cart_event.dart';

import '../menu/bloc/menu_bloc.dart';
import '../menu/bloc/menu_event.dart';

import '../profile/bloc/profile_bloc.dart';
import '../profile/bloc/profile_event.dart';

import '../auth/pages/login_info_page.dart';

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

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _pages = const [
      MenuPage(),
      CartPage(),
      ProfilePage(),
    ];
  }

  /// Check if user is logged in
  Future<bool> _isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }

  /// Show login required dialog
  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Требуется вход'),
          content: const Text(
            'Войдите в аккаунт, чтобы просматривать профиль и оформлять заказы.',
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

  /// Handle tab tap
  Future<void> _handleTabTap(int i) async {
    /// Profile tab index = 2
    if (i == 2) {
      final loggedIn = await _isLoggedIn();

      if (!loggedIn) {
        if (!mounted) return;
        _showLoginRequiredDialog(context);
        return;
      }
    }

    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CartBloc()..add(const CartStarted())),
        BlocProvider(create: (_) => MenuBloc()..add(MenuStarted())),
        BlocProvider(create: (_) => ProfileBloc()..add(const ProfileStarted())),
      ],
      child: Builder(
        builder: (context) {
          if (!_appliedInitialProfile &&
              (widget.initialName != null &&
                  widget.initialName!.isNotEmpty)) {
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
            body: IndexedStack(
              index: _index,
              children: _pages,
            ),
            bottomNavigationBar: Builder(
              builder: (context) {
                final cartCount = context.select<CartBloc, int>(
                  (b) => b.state.items.fold<int>(0, (s, x) => s + x.qty),
                );

                return BottomNavigationBar(
                  currentIndex: _index,
                  onTap: _handleTabTap,
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
        },
      ),
    );
  }
}