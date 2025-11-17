import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<UsersBloc>();

          return Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(16),
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
                              rows: state.filtered.map((u) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(u.id.toString())),
                                    DataCell(Text(u.name ?? '—')),
                                    DataCell(Text(u.phone)),
                                    DataCell(Text(u.role)),
                                    DataCell(Text(u.blocked ? "Blocked" : "Active")),
                                    DataCell(Text(
                                      u.createdAt != null
                                          ? DateFormat("dd.MM.yyyy HH:mm").format(u.createdAt!)
                                          : "—",
                                    )),
                                    DataCell(
                                      IconButton(
                                        icon: Icon(
                                          u.blocked ? Icons.lock_open : Icons.block,
                                          color: u.blocked ? Colors.green : Colors.red,
                                        ),
                                        onPressed: () {
                                          bloc.add(
                                            u.blocked
                                                ? UserUnblocked(u.id)
                                                : UserBlocked(u.id),
                                          );
                                        },
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
          );
        },
      ),
    );
  }
}
