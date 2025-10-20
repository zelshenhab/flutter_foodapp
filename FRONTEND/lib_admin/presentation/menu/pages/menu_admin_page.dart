// lib_admin/presentation/menu/pages/menu_admin_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/menu_admin_bloc.dart';
import '../bloc/menu_admin_event.dart';
import '../bloc/menu_admin_state.dart';
import 'package:flutter_foodapp/presentation/menu/models/menu_item.dart';

class MenuAdminPage extends StatelessWidget {
  const MenuAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MenuAdminBloc, MenuAdminState>(
      listenWhen: (p, n) => p.error != n.error,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Text(
                  'Меню',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                if (state.categories.isNotEmpty)
                  SizedBox(
                    width: 280,
                    child: DropdownButtonFormField<String>(
                      value: state.selectedCategoryId.isEmpty
                          ? state.categories.first.id
                          : state.selectedCategoryId,
                      items: state.categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.title),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          context.read<MenuAdminBloc>().add(
                            MenuCategoryChanged(v),
                          );
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Категория'),
                    ),
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: state.selectedCategoryId.isEmpty
                      ? null
                      : () =>
                            _showDishDialog(context, state.selectedCategoryId),
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить блюдо'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: state.loading
                  ? const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Название')),
                          DataColumn(label: Text('Цена')),
                          DataColumn(label: Text('Действия')),
                        ],
                        rows: state.items.map((d) {
                          return DataRow(
                            cells: [
                              DataCell(Text(d.id)),
                              DataCell(Text(d.name)),
                              DataCell(Text('${d.price} ₽')),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      tooltip: 'Редактировать',
                                      onPressed: () => _showDishDialog(
                                        context,
                                        state.selectedCategoryId,
                                        dish: d,
                                      ),
                                      icon: const Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      tooltip: 'Удалить',
                                      onPressed: () => context
                                          .read<MenuAdminBloc>()
                                          .add(MenuItemDeleted(d)), // ✅
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showDishDialog(
    BuildContext context,
    String categoryId, {
    MenuItemModel? dish,
  }) {
    final nameCtrl = TextEditingController(text: dish?.name ?? '');
    final priceCtrl = TextEditingController(
      text: dish == null ? '' : dish.price.toString(),
    );
    final imageCtrl = TextEditingController(text: dish?.image ?? '');
    final descCtrl = TextEditingController(text: dish?.description ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(dish == null ? 'Добавить блюдо' : 'Редактировать блюдо'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Цена (₽)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: imageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Изображение (URL)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Описание'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final price = num.tryParse(priceCtrl.text.trim()) ?? 0;
              final img = imageCtrl.text.trim();
              final desc = descCtrl.text.trim();
              if (name.isEmpty || price <= 0) return;

              final newDish = MenuItemModel(
                id:
                    dish?.id ??
                    'tmp-${DateTime.now().millisecondsSinceEpoch}', // slug مؤقت لو حابب
                name: name,
                price: price,
                image: img.isEmpty
                    ? 'assets/images/Chicken-Shawarma-8.jpg'
                    : img,
                categoryId: categoryId,
                description: desc.isEmpty ? null : desc,
                serverId: dish?.serverId,
              );

              if (dish == null) {
                context.read<MenuAdminBloc>().add(MenuItemAdded(newDish));
              } else {
                context.read<MenuAdminBloc>().add(MenuItemUpdated(newDish));
              }
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
