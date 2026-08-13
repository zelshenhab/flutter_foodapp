import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/api_client.dart';
import 'package:flutter_foodapp/core/auth/auth_session.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
import 'package:flutter_foodapp/presentation/common/widgets/app_toast.dart';
import 'package:flutter_foodapp/presentation/common/widgets/login_required_dialog.dart';

import '../menu/pages/menu_page.dart';
import '../cart/pages/cart_page.dart';
import '../profile/pages/profile_page.dart';

import '../cart/bloc/cart_bloc.dart';
import '../cart/bloc/cart_event.dart';
import '../cart/bloc/cart_state.dart';

import '../menu/bloc/menu_bloc.dart';
import '../menu/bloc/menu_event.dart';

import '../profile/bloc/profile_bloc.dart';
import '../profile/bloc/profile_event.dart';

import '../../repos/loyalty_repository.dart';
import '../../repos/profile_repository.dart';

class AppShell extends StatefulWidget {
  final String? initialName;
  final String? initialEmail;

  const AppShell({super.key, this.initialName, this.initialEmail});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  int _index = 0;
  bool _appliedInitialProfile = false;
  late final List<Widget> _pages;
  bool _refreshingOnResume = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pages = const [
      MenuPage(),
      CartPage(),
      ProfilePage(),
    ];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshSessionOnResume();
    }
  }

  Future<void> _refreshSessionOnResume() async {
    if (_refreshingOnResume) return;
    _refreshingOnResume = true;
    try {
      await ensureFreshSession();
    } finally {
      _refreshingOnResume = false;
    }
  }

  /// Handle tab tap
  Future<void> _handleTabTap(int i) async {
    /// Profile tab index = 2
    if (i == 2) {
      final loggedIn = await AuthSession.isLoggedIn();

      if (!loggedIn) {
        if (!mounted) return;
        await showLoginRequiredDialog(
          context,
          message: context.l10n.loginRequiredProfile,
        );
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
        BlocProvider(
          create: (_) => ProfileBloc(
            repo: const ProfileRepository(),
            loyaltyRepo: const LoyaltyRepository(),
          )..add(const ProfileStarted()),
        ),
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

          final l10n = context.l10n;

          return BlocListener<CartBloc, CartState>(
            listenWhen: (p, c) => p.error != c.error && c.error != null,
            listener: (context, state) {
              if (state.error != null) {
                AppToast.error(context, state.error!);
              }
            },
            child: Scaffold(
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
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.restaurant_menu),
                        label: l10n.navMenu,
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
                        label: l10n.navCart,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.person_outline),
                        label: l10n.navProfile,
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
