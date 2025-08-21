import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/menu_bloc.dart';
import '../bloc/menu_event.dart';
import '../bloc/menu_state.dart';
import '../widgets/category_chip_list.dart';
import '../widgets/menu_item_tile.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MenuBloc()..add(MenuStarted()),
      child: Scaffold(
        appBar: AppBar(title: const Text("Адам и Ева")),
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
                        const Text("حدث خطأ في تحميل المنيو"),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<MenuBloc>().add(MenuStarted()),
                          child: const Text("إعادة المحاولة"),
                        ),
                      ],
                    ),
                  );
                }
                if (state.categories.isEmpty) {
                  return const Center(child: Text("لا توجد أقسام حالياً"));
                }

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    CategoryChipList(
                      categories: state.categories,
                      selectedId: state.selectedCategoryId,
                      onSelected: (id) => context.read<MenuBloc>().add(
                        MenuCategorySelected(id),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFF2A2A2A)),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          for (final item in state.items)
                            MenuItemTile(
                              item: item,
                              onAdd: () {
                                // context.read<CartBloc>().add(CartItemAdded(item));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "${item.name} добавлено в корзину",
                                    ),
                                  ),
                                );
                              },
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
