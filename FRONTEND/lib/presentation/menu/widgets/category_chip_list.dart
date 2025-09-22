import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryChipList extends StatelessWidget {
  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const CategoryChipList({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemBuilder: (_, i) {
          final c = categories[i];
          final sel = c.id == selectedId;
          return ChoiceChip(
            label: Text(c.title),
            selected: sel,
            onSelected: (_) => onSelected(c.id),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: categories.length,
      ),
    );
  }
}
