import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/models/admin_user.dart';
import '../../../data/repos/users_repo.dart';
import '../bloc/users_bloc.dart';
import '../bloc/users_event.dart';
import '../bloc/users_state.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          UsersBloc(ctx.read<UsersRepo>())..add(const UsersLoaded()),
      child: BlocConsumer<UsersBloc, UsersState>(
        listenWhen: (p, n) => p.error != n.error,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Expanded(child: Text(state.error!)),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            .hideCurrentSnackBar();
                        context
                            .read<UsersBloc>()
                            .add(const UsersErrorDismissed());
                      },
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<UsersBloc>();

          final filteredUsers = state.search.isEmpty
              ? state.data
              : state.data.where((user) {
                  final q = state.search.toLowerCase();
                  return (user.name?.toLowerCase().contains(q) ?? false) ||
                      user.email.toLowerCase().contains(q);
                }).toList();

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    children: [
                      const Text(
                        'Пользователи',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 240,
                        child: TextField(
                          onChanged: (v) =>
                              bloc.add(UsersSearchChanged(v)),
                          decoration: InputDecoration(
                            hintText: 'Поиск по имени / email',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: const Color(0xFF1E1E1E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// STATS
                  Row(
                    children: [
                      _buildStatCard(
                        'Всего пользователей',
                        state.data.length.toString(),
                        Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Активные',
                        state.data
                            .where((u) => !u.blocked)
                            .length
                            .toString(),
                        Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Заблокированы',
                        state.data
                            .where((u) => u.blocked)
                            .length
                            .toString(),
                        Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// TABLE
                  Expanded(
                    child: Card(
                      color: const Color(0xFF121212),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: state.loading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : filteredUsers.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Пользователи не найдены',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              : Scrollbar(
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  thickness: 8,
                                  radius: const Radius.circular(4),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                      width: 1200,
                                      child: Scrollbar(
                                        thumbVisibility: true,
                                        trackVisibility: true,
                                        thickness: 8,
                                        radius: const Radius.circular(4),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: DataTable(
                                            headingTextStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(255, 199, 160, 34),
                                            ),
                                            dataTextStyle:
                                                const TextStyle(color: Colors.white),
                                            columnSpacing: 24,
                                            columns: const [
                                              DataColumn(label: Text('ID')),
                                              DataColumn(label: Text('Имя')),
                                              DataColumn(label: Text('Email')),
                                              DataColumn(label: Text('Роль')),
                                              DataColumn(label: Text('Статус')),
                                              DataColumn(label: Text('Бонусы')),
                                              DataColumn(label: Text('Дата')),
                                              DataColumn(label: Text('Действия')),
                                            ],
                                            rows: filteredUsers.map((user) {
                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                      Text(user.id.toString())),
                                                  DataCell(
                                                    Text(
                                                      user.displayName,
                                                      style: TextStyle(
                                                        fontStyle: user.name == null ||
                                                                user.name!.isEmpty
                                                            ? FontStyle.italic
                                                            : FontStyle.normal,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(Text(user.email)),
                                                  DataCell(
                                                    _roleChip(user.role),
                                                  ),
                                                  DataCell(
                                                    _statusChip(user.blocked),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange
                                                            .withValues(alpha: 0.2),
                                                        borderRadius:
                                                            BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        "${user.loyaltyPoints} ⭐",
                                                        style: const TextStyle(
                                                          color: Colors.orange,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(Text(
                                                    user.createdAt != null
                                                        ? DateFormat("dd.MM.yyyy HH:mm")
                                                            .format(user.createdAt!)
                                                        : "—",
                                                  )),
                                                  DataCell(
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(
                                                            user.blocked
                                                                ? Icons.lock_open
                                                                : Icons.block,
                                                            color: user.blocked
                                                                ? Colors.green
                                                                : Colors.red,
                                                          ),
                                                          onPressed: () {
                                                            if (user.blocked) {
                                                              bloc.add(
                                                                  UserUnblocked(
                                                                      user.id));
                                                            } else {
                                                              bloc.add(
                                                                  UserBlocked(
                                                                      user.id));
                                                            }
                                                          },
                                                        ),
                                                        PopupMenuButton<String>(
                                                          icon: const Icon(
                                                              Icons.more_vert,
                                                              color: Colors.white),
                                                          onSelected: (value) {
                                                            if (value ==
                                                                'change_role') {
                                                              _showRoleDialog(
                                                                  context,
                                                                  user,
                                                                  bloc);
                                                            }
                                                          },
                                                          itemBuilder: (context) => [
                                                            const PopupMenuItem(
                                                              value: 'change_role',
                                                              child: Text(
                                                                  'Изменить роль'),
                                                            ),
                                                          ],
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
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return SizedBox(
      width: 180,
      child: Card(
        color: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleChip(String role) {
    Color color;
    String text;

    switch (role) {
      case 'admin':
        color = const Color.fromARGB(255, 199, 160, 34);
        text = 'Админ';
        break;
      case 'manager':
        color = Colors.purple;
        text = 'Менеджер';
        break;
      default:
        color = Colors.blue;
        text = 'Клиент';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Widget _statusChip(bool blocked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: blocked
            ? Colors.red.withValues(alpha: 0.2)
            : Colors.green.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        blocked ? 'Заблокирован' : 'Активен',
        style: TextStyle(
          color: blocked ? Colors.red : Colors.green,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showRoleDialog(
      BuildContext context, AdminUser user, UsersBloc bloc) {
    final currentRole = user.role;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить роль'),
        content: DropdownButtonFormField<String>(
          initialValue: currentRole,
          items: const [
            DropdownMenuItem(value: 'customer', child: Text('Клиент')),
            DropdownMenuItem(value: 'manager', child: Text('Менеджер')),
            DropdownMenuItem(value: 'admin', child: Text('Админ')),
          ],
          onChanged: (newRole) {
            if (newRole != null && newRole != currentRole) {
              bloc.add(UserRoleChanged(user.id, newRole));
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }
}