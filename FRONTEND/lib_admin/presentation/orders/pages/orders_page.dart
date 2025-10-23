import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repos/orders_repo.dart';
import '../../orders/bloc/orders_bloc.dart';
import '../../orders/bloc/orders_event.dart';
import '../../orders/bloc/orders_state.dart';

import '../../../data/repos/mock_orders_repo.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrdersBloc>(
      create: (_) => OrdersBloc(MockOrdersRepo())..add(const OrdersLoaded()),
      child: BlocConsumer<OrdersBloc, OrdersState>(
        listenWhen: (p, n) => p.error != n.error,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          // بحث محلي (ID/اسم العميل)
          final q = _searchCtrl.text.trim().toLowerCase();
          final visible =
              (q.isEmpty
                      ? state.filtered
                      : state.filtered.where((o) {
                          return o.id.toLowerCase().contains(q) ||
                              o.customer.toLowerCase().contains(q);
                        }))
                  .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  const Text(
                    'Заказы (Самовывоз)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 280,
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Поиск (ID / клиент)',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusFilter(
                    value: state.filter,
                    onChanged: (f) =>
                        context.read<OrdersBloc>().add(OrdersFilterChanged(f)),
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
                            DataColumn(label: Text('Клиент')),
                            DataColumn(label: Text('Тип')),
                            DataColumn(label: Text('Сумма')),
                            DataColumn(label: Text('Оплата')),
                            DataColumn(label: Text('Состав')), // ← جديد
                            DataColumn(label: Text('Статус')),
                            DataColumn(label: Text('Действия')),
                          ],
                          rows: visible.map((o) {
                            return DataRow(
                              cells: [
                                DataCell(Text(o.id)),
                                DataCell(Text(o.customer)),
                                const DataCell(Text('Самовывоз')),
                                DataCell(Text('${o.total} ₽')),
                                DataCell(_PaidPill(paid: o.paid)), // ستايل قديم
                                DataCell(
                                  TextButton.icon(
                                    icon: const Icon(Icons.list_alt),
                                    label: const Text('Позиции'),
                                    onPressed: () =>
                                        _showOrderItems(context, o),
                                  ),
                                ),
                                DataCell(
                                  _OrderStatusPill(
                                    status: o.status,
                                    onChange: (s) => context
                                        .read<OrdersBloc>()
                                        .add(OrderStatusChanged(o.id, s)),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        tooltip: 'В готовку',
                                        onPressed:
                                            (o.paid && o.status == 'pending')
                                            ? () => context
                                                  .read<OrdersBloc>()
                                                  .add(
                                                    OrderStatusChanged(
                                                      o.id,
                                                      'preparing',
                                                    ),
                                                  )
                                            : null,
                                        icon: const Icon(Icons.restaurant),
                                      ),
                                      IconButton(
                                        tooltip: 'Готов к выдаче',
                                        onPressed:
                                            (o.paid &&
                                                (o.status == 'pending' ||
                                                    o.status == 'preparing'))
                                            ? () => context
                                                  .read<OrdersBloc>()
                                                  .add(
                                                    OrderStatusChanged(
                                                      o.id,
                                                      'ready',
                                                    ),
                                                  )
                                            : null,
                                        icon: const Icon(Icons.checklist_rtl),
                                      ),
                                      IconButton(
                                        tooltip: 'Завершён',
                                        onPressed:
                                            (o.paid && o.status == 'ready')
                                            ? () => context
                                                  .read<OrdersBloc>()
                                                  .add(
                                                    OrderStatusChanged(
                                                      o.id,
                                                      'completed',
                                                    ),
                                                  )
                                            : null,
                                        icon: const Icon(Icons.check_circle),
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

  void _showOrderItems(BuildContext context, AdminOrder o) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) {
        final sum = o.items.fold<double>(0, (p, it) => p + it.lineTotal);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Состав заказа #${o.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  _PaidPill(paid: o.paid),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: o.items.map((it) {
                    return ListTile(
                      dense: true,
                      title: Text('${it.qty} × ${it.name}'),
                      trailing: Text('${it.lineTotal.toStringAsFixed(0)} ₽'),
                      subtitle: Text(
                        'Цена: ${it.unitPrice.toStringAsFixed(0)} ₽',
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Spacer(),
                  Text(
                    'Итого по позициям: ${sum.toStringAsFixed(0)} ₽',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Spacer(),
                  Text(
                    'Оплачено: ${o.paid ? 'Да (Карта)' : 'Нет'}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: o.paid ? Colors.greenAccent : Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text('Закрыть'),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }
}

class _PaidPill extends StatelessWidget {
  final bool paid;
  const _PaidPill({required this.paid});

  @override
  Widget build(BuildContext context) {
    final bg = paid ? const Color(0xFF153B2B) : const Color(0xFF3B1B1B);
    final border = paid ? const Color(0xFF1E8E64) : const Color(0xFFB24A4A);
    final text = paid ? const Color(0xFF8EF3C5) : const Color(0xFFFFB1B1);
    final label = paid ? 'Оплачено' : 'Не оплачено';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: text, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StatusFilter extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _StatusFilter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const items = <DropdownMenuItem<String>>[
      DropdownMenuItem(value: 'all', child: Text('Все')),
      DropdownMenuItem(value: 'pending', child: Text('В ожидании')),
      DropdownMenuItem(value: 'preparing', child: Text('Готовится')),
      DropdownMenuItem(value: 'ready', child: Text('Готов к выдаче')),
      DropdownMenuItem(value: 'completed', child: Text('Завершён')),
      DropdownMenuItem(value: 'cancelled', child: Text('Отменён')),
    ];
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: (v) => onChanged(v ?? 'all'),
        decoration: const InputDecoration(labelText: 'Фильтр статуса'),
      ),
    );
  }
}

class _OrderStatusPill extends StatelessWidget {
  final String status;
  final ValueChanged<String> onChange;
  const _OrderStatusPill({required this.status, required this.onChange});

  @override
  Widget build(BuildContext context) {
    const labels = <String, String>{
      'pending': 'В ожидании',
      'preparing': 'Готовится',
      'ready': 'Готов к выдаче',
      'completed': 'Завершён',
      'cancelled': 'Отменён',
    };
    return PopupMenuButton<String>(
      onSelected: onChange,
      itemBuilder: (_) => labels.entries
          .map((e) => PopupMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(labels[status] ?? status),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more, size: 16),
          ],
        ),
      ),
    );
  }
}
