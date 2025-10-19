import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/utils/money.dart';

import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../models/order.dart';
import '../widgets/order_item_row.dart';

class OrderDetailsPage extends StatelessWidget {
  final OrderEntity order;
  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusText(order.status);

    return Scaffold(
      appBar: AppBar(title: Text('Заказ №${order.id}')),
      body: SafeArea(
        child: ListView(
          children: [
            // ===== Header: Restaurant + date/time + status badge
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.restaurant,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _dateTimeString(order.createdAt),
                          style: const TextStyle(color: Color(0xFFA7A7A7)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: Text(
                      statusLabel,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0xFF2A2A2A)),

            // ===== Title: items
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Состав заказа',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),

            // ===== Items list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  for (final it in order.items) ...[
                    OrderItemRow(item: it),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),

            const Divider(color: Color(0xFF2A2A2A)),

            // ===== Summary
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  _row('Сумма заказа', money(order.itemsTotal)),
                  if (order.deliveryFee > 0) // غالبًا صفر في الاستلام الذاتي
                    _row('Доставка', money(order.deliveryFee)),
                  if (order.discount > 0)
                    _row('Скидка', '-${money(order.discount)}'),
                  const Divider(color: Color(0xFF2A2A2A)),
                  _row('Итого', money(order.grandTotal), bold: true),
                ],
              ),
            ),

            // ===== Confirm pickup button (only when ready)
            if (order.status == OrderStatus.ready)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Подтвердить получение'),
                    onPressed: () {
                      // نحاول نقرأ OrdersBloc بأمان (بدون كراش لو مش موجود)
                      final ordersBloc = BlocProvider.of<OrdersBloc>(
                        context,
                        listen: false,
                      );
                      if (ordersBloc == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Не удалось обновить статус: OrdersBloc не найден. '
                              'Проверьте, что вы передали Bloc через BlocProvider.value при навигации.',
                            ),
                          ),
                        );
                        return;
                      }

                      ordersBloc.add(OrderPickupConfirmed(order.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Спасибо! Приятного аппетита.'),
                        ),
                      );
                      Navigator.pop(context); // رجوع لقائمة الطلبов
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ===== Helpers =====

  Widget _row(String l, String v, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            v,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _statusText(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return 'Ожидает';
      case OrderStatus.preparing:
        return 'Готовится';
      case OrderStatus.ready:
        return 'Готов к выдаче';
      case OrderStatus.completed:
        return 'Завершён';
      case OrderStatus.cancelled:
        return 'Отменён';
    }
  }

  String _dateTimeString(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d.$m.$y • $hh:$mm';
  }
}
