import 'package:flutter/material.dart';

class MenuSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  const MenuSearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF1E1E1E);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Color(0xFFEDEDED)),
        decoration: InputDecoration(
          hintText: 'Поиск блюд или категорий',
          hintStyle: const TextStyle(color: Color(0xFFA7A7A7)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFA7A7A7)),
          filled: true,
          fillColor: bg,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
