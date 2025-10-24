import 'package:flutter/material.dart';
import '../../common/widgets/stat_card.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth > 1100;
          final isTablet = c.maxWidth > 700 && !isWide;
          final cross = isWide ? 4 : (isTablet ? 3 : 2);

          final cards = [
            StatCard(
              title: 'Новые заказы (сегодня)',
              value: '24',
              icon: Icons.shopping_cart,
              trendValue: 12, // +12%
              trendIsPositive: true,
              onTap: () {},
            ),
            StatCard(
              title: 'Выручка (сегодня)',
              value: '54 300 ₽',
              icon: Icons.attach_money,
              trendValue: 6, // +6%
              trendIsPositive: true,
              onTap: () {},
            ),
            StatCard(
              title: 'Активные пользователи',
              value: '1 248',
              icon: Icons.people,
              trendValue: -3, // -3%
              trendIsPositive: false,
              onTap: () {},
            ),
            const StatCard(
              title: 'Самовывоз (7 дней)',
              value: '392',
              icon: Icons.store_mall_directory,
              sub: 'Среднее: 56/день',
            ),
          ];

          return Column(
            children: [
              // شريط بحث بسيط للمستقبل (فلترة الجداول/الرسوم)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _search = v),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Поиск по аналитике…',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: cross,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: cards
                      .where(
                        (c) =>
                            _search.trim().isEmpty ||
                            c.title.toLowerCase().contains(
                              _search.toLowerCase(),
                            ),
                      )
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
