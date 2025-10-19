import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tickets_bloc.dart';
import '../bloc/tickets_event.dart';
import '../bloc/tickets_state.dart';

class TicketsPage extends StatelessWidget {
  const TicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TicketsBloc, TicketsState>(
      listenWhen: (p, n) => p.error != n.error,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Text('Поддержка',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const Spacer(),
                _TicketFilter(
                  value: state.filter,
                  onChanged: (f) =>
                      context.read<TicketsBloc>().add(TicketsFilterChanged(f)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: state.loading
                  ? const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()))
                  : Column(
                      children: state.filtered.map((t) {
                        return ListTile(
                          title: Text('#${t.id} — ${t.subject}'),
                          subtitle: Text('${t.customer} • ${t.createdAt}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (t.status == 'open')
                                IconButton(
                                  tooltip: 'Ответить',
                                  onPressed: () => _showReplySheet(context, t.id),
                                  icon: const Icon(Icons.reply),
                                ),
                              IconButton(
                                tooltip: t.status == 'open' ? 'Закрыть' : 'Открыт',
                                onPressed: () {
                                  if (t.status == 'open') {
                                    context.read<TicketsBloc>().add(TicketClosed(t.id));
                                  } else {
                                    // لو حابب تفتح من جديد: ممكن تعمل حدث TicketReopen
                                  }
                                },
                                icon: Icon(
                                  t.status == 'open'
                                      ? Icons.check_circle_outline
                                      : Icons.lock_open,
                                ),
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

  void _showReplySheet(BuildContext context, String ticketId) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ответ пользователю', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Напишите ответ...',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    final text = ctrl.text.trim();
                    if (text.isEmpty) return;
                    context.read<TicketsBloc>().add(TicketReplySent(ticketId, text));
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
      width: 220,
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: (v) => onChanged(v ?? 'all'),
        decoration: const InputDecoration(labelText: 'Фильтр'),
      ),
    );
  }
}
