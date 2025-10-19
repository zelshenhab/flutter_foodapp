import 'package:flutter/material.dart';

class AdminNavRail extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;

  const AdminNavRail({super.key, required this.index, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: index,
      onDestinationSelected: onSelect,
      backgroundColor: const Color(0xFF1A1A1A),
      labelType: NavigationRailLabelType.all,
      minWidth: 72,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard),
          label: Text('Обзор'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.group_outlined), selectedIcon: Icon(Icons.group),
          label: Text('Пользователи'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long),
          label: Text('Заказы'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.restaurant_menu_outlined), selectedIcon: Icon(Icons.restaurant_menu),
          label: Text('Меню'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.percent_outlined), selectedIcon: Icon(Icons.percent),
          label: Text('Акции'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.support_agent_outlined), selectedIcon: Icon(Icons.support_agent),
          label: Text('Поддержка'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings),
          label: Text('Настройки'),
        ),
      ],
    );
  }
}
