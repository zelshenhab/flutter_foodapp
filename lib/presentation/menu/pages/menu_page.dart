import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/menu_bloc.dart';
import '../bloc/menu_event.dart';
import '../bloc/menu_state.dart';
import '../widgets/menu_header.dart';
import '../widgets/menu_search_bar.dart';
import '../widgets/promo_banner.dart';
import '../widgets/category_icon_strip.dart';
import '../widgets/menu_item_tile.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MenuBloc()..add(MenuStarted()),
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<MenuBloc>().add(MenuRefreshed());
            },
            child: BlocBuilder<MenuBloc, MenuState>(
              builder: (context, state) {
                if (state.loading && state.items.isEmpty) {
                  return const _MenuLoadingSkeleton();
                }

                if (state.error != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Ошибка при загрузке меню"),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<MenuBloc>().add(MenuStarted()),
                          child: const Text("Повторить"),
                        ),
                      ],
                    ),
                  );
                }

                // خريطة أيقونات الأقسام (مهم تكون IDs مطابقة للـ MockMenuRepo)
                final iconMap = <String, String>{
                  'shawarma': 'assets/images/Chicken-Shawarma-8.jpg',
                  'box':
                      'assets/images/Chicken-Shawarma-8.jpg', // БОКС С ШАУРМОЙ
                  'roll': 'assets/images/Chicken-Shawarma-8.jpg', // РОЛЛ
                  'eurobox':
                      'assets/images/Chicken-Shawarma-8.jpg', // ЕВРО-БОКС
                  'pizza': 'assets/images/Chicken-Shawarma-8.jpg',
                  'salads': 'assets/images/Chicken-Shawarma-8.jpg',
                  'main': 'assets/images/Chicken-Shawarma-8.jpg',
                  'breakfast': 'assets/images/Chicken-Shawarma-8.jpg',
                  'sauces': 'assets/images/Chicken-Shawarma-8.jpg',
                };

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const MenuHeader(),
                    const SizedBox(height: 8),
                    const MenuSearchBar(),
                    const PromoBanner(),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        'Категории',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (state.categories.isNotEmpty)
                      CategoryIconStrip(
                        categories: state.categories,
                        selectedId: state.selectedCategoryId,
                        iconAssetByCategoryId: iconMap,
                        onSelected: (id) => context.read<MenuBloc>().add(
                          MenuCategorySelected(id),
                        ),
                      ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: Color(0xFF2A2A2A)),

                    // قائمة الأصناف باستخدام ListView.builder لأداء أفضل
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.items.length,
                            itemBuilder: (_, i) => MenuItemTile(
                              item: state.items[i],
                              onAdd: () {
                                // هنوصل لاحقًا بـ CartBloc
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "${state.items[i].name} добавлено в корзину",
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (state.loading) ...[
                            const SizedBox(height: 16),
                            const Center(child: CircularProgressIndicator()),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuLoadingSkeleton extends StatelessWidget {
  const _MenuLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        height: 98,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
      ),
    );
  }
}
