import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
      create: (_) => UsersBloc.withRepo(
        repo: UsersRepo(AdminApiClient(baseUrl: 'http://10.0.2.2:4000/api')),
      )..add(const UsersLoaded()),
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
          return Container(
            alignment: Alignment.topLeft, // ✅ الجدول على الشمال
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العنوان + البحث + زر الإضافة
                Row(
                  children: [
                    const Text(
                      'Пользователи',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 240,
                      child: TextField(
                        onChanged: (v) => context.read<UsersBloc>().add(
                          UsersSearchChanged(v),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Поиск по имени / телефону',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: const Color(0xFF1E1E1E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                      ),
                      onPressed: () => _showAddDialog(context),
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Добавить'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: Card(
                    color: const Color(0xFF121212),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: state.loading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orangeAccent,
                              ),
                              dataTextStyle: const TextStyle(
                                color: Colors.white,
                              ),
                              columns: const [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('Имя')),
                                DataColumn(label: Text('Телефон')),
                                DataColumn(label: Text('Роль')),
                                DataColumn(label: Text('Статус')),
                                DataColumn(label: Text('Дата регистрации')),
                                DataColumn(label: Text('Действия')),
                              ],
                              rows: state.filtered.map((u) {
                                final dateStr = u.createdAt != null
                                    ? DateFormat(
                                        'dd.MM.yyyy HH:mm',
                                      ).format(u.createdAt!)
                                    : '—';
                                return DataRow(
                                  cells: [
                                    DataCell(Text(u.id)),
                                    DataCell(Text(u.name)),
                                    DataCell(Text(u.phone)),
                                    DataCell(
                                      _RoleTag(
                                        role: u.role,
                                        onChange: (r) => context
                                            .read<UsersBloc>()
                                            .add(UserRoleChanged(u.id, r)),
                                      ),
                                    ),
                                    DataCell(_StatusPill(blocked: u.blocked)),
                                    DataCell(Text(dateStr)),
                                    DataCell(
                                      Row(
                                        children: [
                                          if (!u.blocked)
                                            IconButton(
                                              tooltip: 'Заблокировать',
                                              onPressed: () => context
                                                  .read<UsersBloc>()
                                                  .add(UserBlocked(u.id)),
                                              icon: const Icon(
                                                Icons.block,
                                                color: Colors.redAccent,
                                              ),
                                            )
                                          else
                                            IconButton(
                                              tooltip: 'Разблокировать',
                                              onPressed: () async {
                                                final ok = await context
                                                    .read<UsersBloc>()
                                                    .repo
                                                    .unblockUser(u.id);
                                                if (ok) {
                                                  context.read<UsersBloc>().add(
                                                    const UsersLoaded(),
                                                  );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Пользователь разблокирован',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.lock_open,
                                                color: Colors.greenAccent,
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🟧 Dialog لإضافة مستخدم جديد
  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String role = 'customer';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Добавить пользователя',
          style: TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Имя',
                    filled: true,
                    fillColor: Color(0xFF2A2A2A),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Телефон',
                    filled: true,
                    fillColor: Color(0xFF2A2A2A),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  dropdownColor: const Color(0xFF2A2A2A),
                  value: role,
                  decoration: const InputDecoration(labelText: 'Роль'),
                  items: const [
                    DropdownMenuItem(
                      value: 'customer',
                      child: Text('Покупатель'),
                    ),
                    DropdownMenuItem(value: 'manager', child: Text('Менеджер')),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Администратор'),
                    ),
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
            child: const Text(
              'Отмена',
              style: TextStyle(color: Colors.orangeAccent),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
            ),
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

// 🟩 الوسم الخاص بالدور (بالروسي)
class _RoleTag extends StatelessWidget {
  final String role;
  final ValueChanged<String> onChange;
  const _RoleTag({required this.role, required this.onChange});

  String get roleRu {
    switch (role) {
      case 'admin':
        return 'Администратор';
      case 'manager':
        return 'Менеджер';
      default:
        return 'Покупатель';
    }
  }

  Color _color(String r) {
    switch (r) {
      case 'admin':
        return Colors.redAccent;
      case 'manager':
        return Colors.amber;
      default:
        return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: const Color(0xFF1E1E1E),
      onSelected: onChange,
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'customer', child: Text('Покупатель')),
        PopupMenuItem(value: 'manager', child: Text('Менеджер')),
        PopupMenuItem(value: 'admin', child: Text('Администратор')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: _color(role).withOpacity(0.15),
          border: Border.all(color: _color(role)),
        ),
        child: Text(
          roleRu,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: _color(role),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// 🟣 حالة المستخدم (نشط / محظور)
class _StatusPill extends StatelessWidget {
  final bool blocked;
  const _StatusPill({required this.blocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: blocked
            ? Colors.redAccent.withOpacity(0.15)
            : Colors.greenAccent.withOpacity(0.15),
        border: Border.all(
          color: blocked ? Colors.redAccent : Colors.greenAccent,
        ),
      ),
      child: Text(
        blocked ? 'Заблокирован' : 'Активен',
        style: TextStyle(
          color: blocked ? Colors.redAccent : Colors.greenAccent,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
