import 'package:flutter/material.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? trailing;

  /// كولباك البحث (اختياري)
  final ValueChanged<String>? onSearchChanged;

  /// نص الـ hint في البحث
  final String searchHint;

  /// إظهار مربع البحث من عدمه
  final bool showSearch;

  const AdminAppBar({
    super.key,
    required this.title,
    this.trailing,
    this.onSearchChanged,
    this.searchHint = 'Поиск…',
    this.showSearch = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return AppBar(
      title: Text(title),
      actions: [
        if (showSearch)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: TextField(
                controller: controller,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: searchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    tooltip: 'Очистить',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      controller.clear();
                      onSearchChanged?.call('');
                    },
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(width: 12),
        IconButton(
          tooltip: 'Уведомления',
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFF2A2A2A),
          child: Icon(Icons.person, size: 18),
        ),
        const SizedBox(width: 8),
        if (trailing != null) trailing!,
        const SizedBox(width: 12),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: Color(0xFF2A2A2A)),
      ),
    );
  }
}
