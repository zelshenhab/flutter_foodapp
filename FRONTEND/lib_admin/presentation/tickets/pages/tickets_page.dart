import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repos/tickets_repo.dart';
import '../bloc/tickets_bloc.dart';
import '../bloc/tickets_event.dart';
import '../bloc/tickets_state.dart'; // Mock/HTTP Repo

class TicketsPage extends StatelessWidget {
  const TicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TicketsBloc>(
      create: (_) => TicketsBloc(TicketsRepo())..add(const TicketsLoaded()),
      child: const _TicketsView(),
    );
  }
}

class _TicketsView extends StatefulWidget {
  const _TicketsView({super.key});

  @override
  State<_TicketsView> createState() => _TicketsViewState();
}

class _TicketsViewState extends State<_TicketsView> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TicketsBloc, TicketsState>(
      listenWhen: (p, n) => p.error != n.error,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        final filtered = state.filtered.where((t) {
          final q = _search.trim().toLowerCase();
          if (q.isEmpty) return true;
          return t.customer.toLowerCase().contains(q) ||
              t.subject.toLowerCase().contains(q) ||
              t.id.contains(q);
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildKpiRow(state),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Поиск (ID / клиент / тема)',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _TicketFilter(
                  value: state.filter,
                  onChanged: (f) =>
                      context.read<TicketsBloc>().add(TicketsFilterChanged(f)),
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
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      children: filtered.isEmpty
                          ? const [
                              SizedBox(height: 80),
                              Center(child: Text('Заявок нет')),
                              SizedBox(height: 80),
                            ]
                          : filtered.map((t) {
                              return ListTile(
                                leading: Text(
                                  t.status == 'open' ? '📩' : '🔒',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                title: Text('#${t.id} — ${t.subject}'),
                                subtitle: Text(
                                    '${t.customer} • ${t.createdAt} • ${t.status == 'open' ? 'открыта' : 'закрыта'}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Посмотреть',
                                      icon: const Icon(
                                          Icons.visibility_outlined),
                                      onPressed: () => _showTicketDetails(
                                          context, t),
                                    ),
                                    if (t.status == 'open')
                                      IconButton(
                                        tooltip: 'Закрыть заявку',
                                        onPressed: () => context
                                            .read<TicketsBloc>()
                                            .add(TicketClosed(t.id)),
                                        icon: const Icon(Icons.lock),
                                      )
                                    else
                                      IconButton(
                                        tooltip: 'Открыть снова',
                                        onPressed: () => context
                                            .read<TicketsBloc>()
                                            .add(TicketReopened(t.id)),
                                        icon: const Icon(Icons.lock_open),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiRow(TicketsState s) {
    return Row(
      children: [
        _KpiCard(label: 'Всего', value: '${s.total}'),
        const SizedBox(width: 8),
        _KpiCard(label: 'Открыты', value: '${s.openCount}', color: Colors.green),
        const SizedBox(width: 8),
        _KpiCard(label: 'Закрыты', value: '${s.closedCount}', color: Colors.orange),
      ],
    );
  }

  void _showTicketDetails(BuildContext context, AdminTicket t) {
    final replyCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Заявка #${t.id}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 18)),
              Text('Клиент: ${t.customer}',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              Text('Тема: ${t.subject}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const Divider(),
              const Text('Сообщения:',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              ...t.messages.map((m) => Align(
                    alignment: m.sender == 'admin'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: m.sender == 'admin'
                            ? Colors.blueGrey.shade700
                            : Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(m.message),
                    ),
                  )),
              const SizedBox(height: 10),
              TextField(
                controller: replyCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Введите ответ...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    final msg = replyCtrl.text.trim();
                    if (msg.isEmpty) return;
                    context
                        .read<TicketsBloc>()
                        .add(TicketReplySent(t.id, msg));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Отправить'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _KpiCard({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 70,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: color ?? Colors.white,
              ),
            ),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _TicketFilter extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _TicketFilter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const items = <DropdownMenuItem<String>>[
      DropdownMenuItem(value: 'all', child: Text('Все')),
      DropdownMenuItem(value: 'open', child: Text('Открытые')),
      DropdownMenuItem(value: 'closed', child: Text('Закрытые')),
    ];
    return SizedBox(
      width: 160,
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: (v) => onChanged(v ?? 'all'),
        decoration: const InputDecoration(labelText: 'Статус'),
      ),
    );
  }
}
