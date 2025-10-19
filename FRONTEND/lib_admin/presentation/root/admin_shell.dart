import 'package:flutter/material.dart';
import '../common/widgets/admin_app_bar.dart';
import '../common/widgets/admin_nav_rail.dart';
import '../dashboard/pages/analytics_page.dart';
import '../users/pages/users_page.dart';
import '../orders/pages/orders_page.dart';
import '../menu/pages/menu_admin_page.dart';
import '../promos/pages/promos_admin_page.dart';
import '../tickets/pages/tickets_page.dart';
import '../settings/pages/settings_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      AnalyticsPage(),
      UsersPage(),
      OrdersPage(),
      MenuAdminPage(),
      PromosAdminPage(),
      TicketsPage(),
      SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(title: 'Адам и Ева • Admin'),
      body: Row(
        children: [
          AdminNavRail(index: _index, onSelect: (i) => setState(() => _index = i)),
          const VerticalDivider(width: 1, color: Color(0xFF2A2A2A)),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _pages[_index],
            ),
          ),
        ],
      ),
    );
  }
}
