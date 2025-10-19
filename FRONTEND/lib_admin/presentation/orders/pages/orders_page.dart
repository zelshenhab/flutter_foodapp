import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrdersBloc, OrdersState>(
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
                  'Заказы (Самовывоз)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
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
                          DataColumn(label: Text('Статус')),
                          DataColumn(label: Text('Действия')),
                        ],
                        rows: state.filtered.map((o) {
                          return DataRow(
                            cells: [
                              DataCell(Text(o.id)),
                              DataCell(Text(o.customer)),
                              const DataCell(Text('Самовывоз')),
                              DataCell(Text('${o.total} ₽')),
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
                                    // إرسال إلى التحضير
                                    IconButton(
                                      tooltip: 'В готовку',
                                      onPressed: o.status == 'pending'
                                          ? () =>
                                                context.read<OrdersBloc>().add(
                                                  OrderStatusChanged(
                                                    o.id,
                                                    'preparing',
                                                  ),
                                                )
                                          : null,
                                      icon: const Icon(Icons.restaurant),
                                    ),
                                    // جاهز للاستلام
                                    IconButton(
                                      tooltip: 'Готов к выдаче',
                                      onPressed:
                                          (o.status == 'pending' ||
                                              o.status == 'preparing')
                                          ? () =>
                                                context.read<OrdersBloc>().add(
                                                  OrderStatusChanged(
                                                    o.id,
                                                    'ready',
                                                  ),
                                                )
                                          : null,
                                      icon: const Icon(Icons.checklist_rtl),
                                    ),
                                    // تم الاستلام
                                    IconButton(
                                      tooltip: 'Завершён',
                                      onPressed: (o.status == 'ready')
                                          ? () =>
                                                context.read<OrdersBloc>().add(
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
      width: 240,
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
