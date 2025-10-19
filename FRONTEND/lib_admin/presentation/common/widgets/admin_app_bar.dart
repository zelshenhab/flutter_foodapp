import 'package:flutter/material.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? trailing;

  const AdminAppBar({super.key, required this.title, this.trailing});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        SizedBox(
          width: 320,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Поиск…',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFF2A2A2A),
          child: Icon(Icons.person, size: 18),
        ),
        const SizedBox(width: 16),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: Color(0xFF2A2A2A)),
      ),
    );
  }
}
