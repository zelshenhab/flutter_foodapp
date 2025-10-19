import 'package:flutter/material.dart';
import '../../common/widgets/stat_card.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth > 900;
          final cross = isWide ? 4 : 2;
          return GridView.count(
            crossAxisCount: cross,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: const [
              StatCard(
                title: 'Новые заказы (сегодня)',
                value: '24',
                icon: Icons.shopping_cart,
              ),
              StatCard(
                title: 'Выручка (сегодня)',
                value: '54 300 ₽',
                icon: Icons.attach_money,
              ),
              StatCard(
                title: 'Активные пользователи',
                value: '1 248',
                icon: Icons.people,
              ),
              StatCard(
                title: 'Самовывоз (7 дней)',
                value: '392',
                icon: Icons.store_mall_directory,
              ),
            ],
          );
        },
      ),
    );
  }
}
