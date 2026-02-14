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
      create: (ctx) => UsersBloc(ctx.read<UsersRepo>())..add(const UsersLoaded()),
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
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        context.read<UsersBloc>().add(const UsersErrorDismissed());
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

          // Filter users based on search
          final filteredUsers = state.search.isEmpty
              ? state.data
              : state.data.where((user) {
                  final searchLower = state.search.toLowerCase();
                  return (user.name?.toLowerCase().contains(searchLower) ?? false) ||
                         user.email.toLowerCase().contains(searchLower);
                }).toList();

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Пользователи',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 240,
                          child: TextField(
                            onChanged: (v) => bloc.add(UsersSearchChanged(v)),
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
                      ],
                    ),

                    const SizedBox(height: 16),

                    // User stats
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatCard(
                            'Всего пользователей',
                            state.data.length.toString(),
                            Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            'Активные',
                            state.data.where((u) => !u.blocked).length.toString(),
                            Colors.green,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            'Заблокированы',
                            state.data.where((u) => u.blocked).length.toString(),
                            Colors.red,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Users table
                    Card(
                      color: const Color(0xFF121212),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: state.loading
                          ? const SizedBox(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : filteredUsers.isEmpty
                              ? const SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: Text(
                                      'Пользователи не найдены',
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                )
                              : SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      headingTextStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orangeAccent,
                                      ),
                                      dataTextStyle: const TextStyle(color: Colors.white),
                                      columns: const [
                                        DataColumn(label: Text('ID')),
                                        DataColumn(label: Text('Имя')),
                                        DataColumn(label: Text('Телефон')),
                                        DataColumn(label: Text('Роль')),
                                        DataColumn(label: Text('Статус')),
                                        DataColumn(label: Text('Дата регистрации')),
                                        DataColumn(label: Text('Действия')),
                                      ],
                                      rows: filteredUsers.map((user) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(user.id.toString())),
                                            DataCell(
                                              Text(
                                                user.displayName,
                                                style: TextStyle(
                                                  fontStyle: user.name == null || user.name!.isEmpty
                                                      ? FontStyle.italic
                                                      : FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            DataCell(Text(user.email)),
                                            DataCell(
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _getRoleColor(user.role),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  _getRoleDisplayName(user.role),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: user.blocked 
                                                      ? Colors.red.withOpacity(0.2) 
                                                      : Colors.green.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  user.blocked ? 'Заблокирован' : 'Активен',
                                                  style: TextStyle(
                                                    color: user.blocked ? Colors.red : Colors.green,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(Text(
                                              user.createdAt != null
                                                  ? DateFormat("dd.MM.yyyy HH:mm").format(user.createdAt!)
                                                  : "—",
                                            )),
                                            DataCell(
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(
                                                      user.blocked ? Icons.lock_open : Icons.block,
                                                      color: user.blocked ? Colors.green : Colors.red,
                                                      size: 20,
                                                    ),
                                                    tooltip: user.blocked ? 'Разблокировать' : 'Заблокировать',
                                                    onPressed: () {
                                                      if (user.blocked) {
                                                        bloc.add(UserUnblocked(user.id));
                                                      } else {
                                                        bloc.add(UserBlocked(user.id));
                                                      }
                                                    },
                                                  ),
                                                  PopupMenuButton<String>(
                                                    icon: const Icon(Icons.more_vert, color: Colors.white),
                                                    onSelected: (value) {
                                                      if (value == 'change_role') {
                                                        _showRoleDialog(context, user, bloc);
                                                      }
                                                    },
                                                    itemBuilder: (context) => [
                                                      const PopupMenuItem(
                                                        value: 'change_role',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.swap_horiz, size: 18),
                                                            SizedBox(width: 8),
                                                            Text('Изменить роль'),
                                                          ],
                                                        ),
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

                    const SizedBox(height: 16),

                    // Pagination
                    if (state.totalPages > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: state.page > 1
                                ? () => bloc.add(UsersPageChanged(state.page - 1))
                                : null,
                          ),
                          Text(
                            "Страница ${state.page} из ${state.totalPages}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward, color: Colors.white),
                            onPressed: state.page < state.totalPages
                                ? () => bloc.add(UsersPageChanged(state.page + 1))
                                : null,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: 180,
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
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

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.orange;
      case 'manager':
        return Colors.purple;
      case 'customer':
      default:
        return Colors.blue;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Админ';
      case 'manager':
        return 'Менеджер';
      case 'customer':
      default:
        return 'Клиент';
    }
  }

  void _showRoleDialog(BuildContext context, AdminUser user, UsersBloc bloc) {
    final currentRole = user.role;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить роль пользователя'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Пользователь: ${user.displayName}'),
            const SizedBox(height: 16),
            const Text('Выберите новую роль:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: currentRole,
              items: const [
                DropdownMenuItem(value: 'customer', child: Text('Клиент')),
                DropdownMenuItem(value: 'manager', child: Text('Менеджер')),
                DropdownMenuItem(value: 'admin', child: Text('Администратор')),
              ],
              onChanged: (newRole) {
                if (newRole != null && newRole != currentRole) {
                  bloc.add(UserRoleChanged(user.id, newRole));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }
}