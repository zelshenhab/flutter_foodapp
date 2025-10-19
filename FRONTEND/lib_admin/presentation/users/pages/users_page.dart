import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repos/users_repo.dart';
import '../../../data/admin_api_client.dart';
import '../bloc/users_bloc.dart';
import '../bloc/users_event.dart';
import '../bloc/users_state.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // وفّر الـ Bloc هنا مباشرةً (سهل للدمج)
      create: (_) =>
          UsersBloc(UsersRepo(AdminApiClient(baseUrl: '.....')))
            ..add(const UsersLoaded()),
      child: BlocConsumer<UsersBloc, UsersState>(
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
                    'Пользователи',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 280,
                    child: TextField(
                      onChanged: (v) =>
                          context.read<UsersBloc>().add(UsersSearchChanged(v)),
                      decoration: const InputDecoration(
                        hintText: 'Поиск по имени / телефону',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDialog(context),
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Добавить'),
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
                            DataColumn(label: Text('Имя')),
                            DataColumn(label: Text('Телефон')),
                            DataColumn(label: Text('Роль')),
                            DataColumn(label: Text('Действия')),
                          ],
                          rows: state.filtered.map((u) {
                            return DataRow(
                              cells: [
                                DataCell(Text(u.id)),
                                DataCell(Text(u.name)),
                                DataCell(Text(u.phone)),
                                DataCell(
                                  _RolePill(
                                    role: u.role,
                                    onChange: (r) => context
                                        .read<UsersBloc>()
                                        .add(UserRoleChanged(u.id, r)),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        tooltip: 'Заблокировать',
                                        onPressed: () => context
                                            .read<UsersBloc>()
                                            .add(UserBlocked(u.id)),
                                        icon: const Icon(Icons.block),
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
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String role = 'customer';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Добавить пользователя'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(hintText: 'Имя'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(hintText: 'Телефон'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Роль'),
                  items: const [
                    DropdownMenuItem(
                      value: 'customer',
                      child: Text('customer'),
                    ),
                    DropdownMenuItem(value: 'manager', child: Text('manager')),
                    DropdownMenuItem(value: 'admin', child: Text('admin')),
                  ],
                  onChanged: (v) => setState(() => role = v ?? 'customer'),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final n = nameCtrl.text.trim();
              final p = phoneCtrl.text.trim();
              if (n.isEmpty || p.isEmpty) return;
              context.read<UsersBloc>().add(UserAdded(n, p, role: role));
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  final String role;
  final ValueChanged<String> onChange;
  const _RolePill({required this.role, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChange,
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'customer', child: Text('customer')),
        PopupMenuItem(value: 'manager', child: Text('manager')),
        PopupMenuItem(value: 'admin', child: Text('admin')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            // بنعرض القيمة الحالية بالنص
          ],
        ),
      ),
    );
  }
}
