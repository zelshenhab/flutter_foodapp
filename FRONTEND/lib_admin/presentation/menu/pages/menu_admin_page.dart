import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/menu_admin_bloc.dart';
import '../bloc/menu_admin_event.dart';
import '../bloc/menu_admin_state.dart';

class MenuAdminPage extends StatelessWidget {
  const MenuAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MenuAdminBloc, MenuAdminState>(
      listenWhen: (p, n) => p.error != n.error,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        final bloc = context.read<MenuAdminBloc>();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---------- HEADER ----------
            Row(
              children: [
                const Text(
                  'Меню',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const Spacer(),

                // ---------- CATEGORY DROPDOWN ----------
                if (state.categories.isNotEmpty)
                  SizedBox(
                    width: 280,
                    child: DropdownButtonFormField<String>(
                      initialValue: state.selectedCategoryId.isEmpty
                          ? state.categories.first["id"].toString()
                          : state.selectedCategoryId,
                      items: state.categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c["id"].toString(),
                              child: Text(c["title"]),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          bloc.add(MenuCategoryChanged(v));
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Категория'),
                    ),
                  ),

                const SizedBox(width: 10),

                // ---------- ADD DISH ----------
                ElevatedButton.icon(
                  onPressed: state.selectedCategoryId.isEmpty
                      ? null
                      : () =>
                          _showDishDialog(context, state.selectedCategoryId),
                  icon: const Icon(Icons.add),
                  label: const Text("Добавить блюдо"),
                )
              ],
            ),

            const SizedBox(height: 16),

            // ---------- TABLE ----------
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: state.loading
                  ? const SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text("ID")),
                          DataColumn(label: Text("Название")),
                          DataColumn(label: Text("Цена")),
                          DataColumn(label: Text("Действия")),
                        ],
                        rows: state.items.map((item) {
                          return DataRow(
                            cells: [
                              DataCell(Text(item["id"].toString())),
                              DataCell(Text(item["title"] ?? "-")),
                              DataCell(Text('${item["basePrice"]} ₽')),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _showDishDialog(
                                        context,
                                        state.selectedCategoryId,
                                        dish: item,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => bloc.add(
                                        MenuItemDeleted(item),
                                      ),
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

  // ---------- ADD / EDIT DIALOG ----------
  void _showDishDialog(
    BuildContext context,
    String categoryId, {
    Map<String, dynamic>? dish,
  }) {
    final nameCtrl = TextEditingController(text: dish?["title"] ?? "");
    final priceCtrl = TextEditingController(
        text: dish?["basePrice"]?.toString() ?? "");
    final imageCtrl = TextEditingController(text: dish?["imageUrl"] ?? "");
    final descCtrl = TextEditingController(text: dish?["description"] ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(dish == null ? "Добавить блюдо" : "Редактировать блюдо"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Название"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Цена"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: imageCtrl,
                decoration:
                    const InputDecoration(labelText: "Изображение URL"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Описание"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Отмена"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final price = num.tryParse(priceCtrl.text.trim()) ?? 0;

              if (name.isEmpty || price <= 0) return;

              final map = {
                "id": dish?["id"] ??
                    "tmp-${DateTime.now().millisecondsSinceEpoch}",
                "title": name,
                "basePrice": price,
                "imageUrl": imageCtrl.text.trim(),
                "description": descCtrl.text.trim(),
                "categoryId": categoryId,
              };

              final bloc = context.read<MenuAdminBloc>();

              if (dish == null) {
                bloc.add(MenuItemAdded(map));
              } else {
                bloc.add(MenuItemUpdated(map));
              }

              Navigator.pop(context);
            },
            child: const Text("Сохранить"),
          )
        ],
      ),
    );
  }
}