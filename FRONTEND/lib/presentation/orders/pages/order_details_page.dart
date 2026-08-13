import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
import 'package:flutter_foodapp/core/services/notification_service.dart';
import 'package:flutter_foodapp/core/utils/money.dart';
import 'package:flutter_foodapp/presentation/common/widgets/app_toast.dart';
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
  String? _lastStatus;
  Timer? _pollTimer;
  bool _polling = false;

  @override
  void initState() {
    super.initState();
    _lastStatus = widget.order.status;
    _loadOrder(initial: true);
    _startPollingIfNeeded(widget.order.status);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  bool _isLiveStatus(String status) =>
      status == 'pending' || status == 'preparing' || status == 'ready';

  void _startPollingIfNeeded(String status) {
    if (!_isLiveStatus(status)) {
      _pollTimer?.cancel();
      _pollTimer = null;
      return;
    }
    if (_pollTimer != null && _pollTimer!.isActive) return;

    _pollTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      _loadOrder(silent: true);
    });
  }

  Future<void> _loadOrder({bool initial = false, bool silent = false}) async {
    if (_polling) return;
    _polling = true;

    try {
      final result = await _repo.getOrderDetail(widget.order.id);
      if (!mounted) return;

      final previous = _lastStatus ?? fullOrder?.status ?? widget.order.status;
      _lastStatus = result.status;

      setState(() {
        fullOrder = result;
        if (initial || !silent) loading = false;
      });

      _maybeNotifyReady(previous: previous, next: result.status, orderId: result.id);
      _patchParentBloc(result);
      _startPollingIfNeeded(result.status);
    } catch (e) {
      debugPrint('❌ OrderDetails error: $e');
      if (!mounted) return;
      if (initial) setState(() => loading = false);
    } finally {
      _polling = false;
    }
  }

  Future<void> _maybeNotifyReady({
    required String previous,
    required String next,
    required int orderId,
  }) async {
    if (previous == 'ready' || next != 'ready') return;
    if (!mounted) return;
    final l10n = context.l10n;
    await NotificationService.notifyOrderReadyOnce(
      orderId: orderId,
      title: l10n.orderReadyTitle,
      body: l10n.orderReadyBody(orderId),
    );
  }

  void _patchParentBloc(OrderModel order) {
    try {
      context.read<OrdersBloc>().add(
            OrderStatusPatched(order.id, order.status),
          );
    } catch (_) {
      // Details can be opened without a parent OrdersBloc.
    }
  }

  Future<void> _confirmPickup(OrderModel order) async {
    final l10n = context.l10n;

    try {
      context.read<OrdersBloc>().add(OrderPickupConfirmed(order.id));
    } catch (_) {
      try {
        await _repo.confirmPickup(order.id);
      } catch (e) {
        if (!mounted) return;
        AppToast.error(context, l10n.ordersRefreshError);
        return;
      }
    }

    if (!mounted) return;
    AppToast.success(context, l10n.enjoyMeal);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final order = fullOrder ?? widget.order;
    final statusLabel = l10n.statusText(order.status);

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orderNumber(order.id)),
        leading: Navigator.canPop(context) ? const BackButton() : null,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadOrder(silent: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.brandPickup,
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
                          horizontal: 8, vertical: 4),
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
              if (order.addressText.isNotEmpty) ...[
                const Divider(color: Color(0xFF2A2A2A)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: Color.fromARGB(255, 199, 160, 34),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.pickupLocation,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order.addressText,
                              style: const TextStyle(
                                color: Color(0xFFA7A7A7),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Divider(color: Color(0xFF2A2A2A)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  l10n.orderComposition,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (order.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.noItemsInOrder,
                    style: const TextStyle(color: Colors.grey),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    _row(l10n.orderSum, money(order.subtotal)),
                    if (order.deliveryFee > 0)
                      _row(l10n.serviceFee, money(order.deliveryFee)),
                    if (order.discount > 0)
                      _row(l10n.discount, '-${money(order.discount)}'),
                    const Divider(color: Color(0xFF2A2A2A)),
                    _row(l10n.total, money(order.total), bold: true),
                  ],
                ),
              ),
              if (order.status == 'ready')
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(l10n.confirmPickup),
                      onPressed: () => _confirmPickup(order),
                    ),
                  ),
                ),
            ],
          ),
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
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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
