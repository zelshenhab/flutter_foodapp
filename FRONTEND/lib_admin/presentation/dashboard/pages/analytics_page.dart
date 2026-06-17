import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/widgets/stat_card.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _search = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    final bloc = context.read<AnalyticsBloc>();

    // initial load
    bloc.add(const AnalyticsLoad());

    // auto refresh every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      bloc.add(const AnalyticsLoad());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        print("🖥️ UI STATE SUMMARY: ${state.summary}"); // 👈 ADD HERE
        print("🖥️ UI STATE ORDERS: ${state.ordersByStatus}"); // 👈 ADD HERE
        final summary = state.summary;
        final orders = state.ordersByStatus;

        final cards = [
          StatCard(
            title: 'Новые заказы (сегодня)',
            value: orders["pending"]?.toString() ?? '0',
            icon: Icons.shopping_cart,
            trendValue: 0,
            trendIsPositive: true,
            onTap: () {},
          ),
          StatCard(
            title: 'Выручка (сегодня)',
            value: '${summary["totalRevenue"] ?? 0} ₽',
            icon: Icons.attach_money,
            trendValue: 0,
            trendIsPositive: true,
            onTap: () {},
          ),
          StatCard(
            title: 'Активные пользователи',
            value: (summary["activeUsers"] ?? 0).toString(),
            icon: Icons.people,
            trendValue: 0,
            trendIsPositive: true,
            onTap: () {},
          ),
          StatCard(
            title: 'Самовывоз (7 дней)',
            value: '—',
            icon: Icons.store_mall_directory,
            sub: 'Среднее: —',
          ),
        ];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, c) {
              final isWide = c.maxWidth > 1100;
              final isTablet = c.maxWidth > 700 && !isWide;
              final cross = isWide ? 4 : (isTablet ? 3 : 2);

              return Column(
                children: [
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
                      if (state.loading)
                        const Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: CircularProgressIndicator(),
                        )
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
                                c.title
                                    .toLowerCase()
                                    .contains(_search.toLowerCase()),
                          )
                          .toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}