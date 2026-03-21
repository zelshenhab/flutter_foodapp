import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/utils/money.dart';
import '../../../repos/orders_repository.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../models/order_model.dart';
import '../widgets/order_item_row.dart';

class OrderDetailsPage extends StatefulWidget {
  final OrderModel order;

  const OrderDetailsPage({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final OrdersRepository _repo = const OrdersRepository();

  OrderModel? fullOrder;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    try {
      final result = await _repo.getOrderDetail(widget.order.id);

      setState(() {
        fullOrder = result;
        loading = false;
      });
    } catch (e) {
      debugPrint('❌ OrderDetails error: $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = fullOrder ?? widget.order;
    final statusLabel = _statusText(order.status);

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Заказ №${order.id}'),
        leading: Navigator.canPop(context)
            ? const BackButton()
            : null,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            /// ===== Header =====
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Адам и Ева — Самовывоз',
                          style: TextStyle(fontWeight: FontWeight.w800),
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
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: const Color(0xFF2A2A2A)),
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

            /// ===== Items =====
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Состав заказа',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),

            if (order.items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Нет товаров в заказе',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: order.items
                      .map(
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: OrderItemRow(item: i),
                        ),
                      )
                      .toList(),
                ),
              ),

            const Divider(color: Color(0xFF2A2A2A)),

            /// ===== Summary =====
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  _row('Сумма заказа', money(order.subtotal)),
                  if (order.deliveryFee > 0)
                    _row('Сервис', money(order.deliveryFee)),
                  if (order.discount > 0)
                    _row('Скидка', '-${money(order.discount)}'),
                  const Divider(color: Color(0xFF2A2A2A)),
                  _row('Итого', money(order.total), bold: true),
                ],
              ),
            ),

            /// ===== Confirm Pickup =====
            if (order.status == 'ready')
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Подтвердить получение'),
                    onPressed: () {
                      context
                          .read<OrdersBloc>()
                          .add(OrderPickupConfirmed(order.id));

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Спасибо! Приятного аппетита.'),
                        ),
                      );

                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight:
                    bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight:
                  bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'Ожидает';
      case 'preparing':
        return 'Готовится';
      case 'ready':
        return 'Готов к выдаче';
      case 'completed':
        return 'Завершён';
      case 'cancelled':
        return 'Отменён';
      default:
        return status;
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