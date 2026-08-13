import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
import 'package:flutter_foodapp/core/services/notification_service.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';
import '../models/order_model.dart';
import '../widgets/order_card.dart';
import 'order_details_page.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (_) => OrdersBloc()..add(OrdersStarted()),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.myOrders)),
        body: const _OrdersLiveBody(),
      ),
    );
  }
}

class _OrdersLiveBody extends StatefulWidget {
  const _OrdersLiveBody();

  @override
  State<_OrdersLiveBody> createState() => _OrdersLiveBodyState();
}

class _OrdersLiveBodyState extends State<_OrdersLiveBody> {
  Timer? _pollTimer;
  final Map<int, String> _knownStatuses = {};
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted) return;
      final state = context.read<OrdersBloc>().state;
      final hasActive = state.orders.any((o) => o.isActive);
      if (hasActive) {
        context.read<OrdersBloc>().add(OrdersRefreshed());
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _onOrdersUpdated(List<OrderModel> orders) async {
    if (!_seeded) {
      for (final o in orders) {
        _knownStatuses[o.id] = o.status;
      }
      _seeded = true;
      return;
    }

    final l10n = context.l10n;
    for (final order in orders) {
      final prev = _knownStatuses[order.id];
      _knownStatuses[order.id] = order.status;
      if (prev != null && prev != 'ready' && order.status == 'ready') {
        await NotificationService.notifyOrderReadyOnce(
          orderId: order.id,
          title: l10n.orderReadyTitle,
          body: l10n.orderReadyBody(order.id),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<OrdersBloc, OrdersState>(
      listenWhen: (p, c) => p.orders != c.orders,
      listener: (context, state) {
        _onOrdersUpdated(state.orders);
      },
      builder: (context, state) {
        if (state.loading && state.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null && state.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      context.read<OrdersBloc>().add(OrdersStarted()),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          );
        }
        if (state.orders.isEmpty) {
          return Center(
            child: Text(
              l10n.noOrdersYet,
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<OrdersBloc>().add(OrdersRefreshed());
            await Future<void>.delayed(const Duration(milliseconds: 400));
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: state.orders.length,
            itemBuilder: (context, index) {
              final order = state.orders[index];
              return OrderCard(
                order: order,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<OrdersBloc>(),
                        child: OrderDetailsPage(order: order),
                      ),
                    ),
                  ).then((_) {
                    if (context.mounted) {
                      context.read<OrdersBloc>().add(OrdersRefreshed());
                    }
                  });
                },
              );
            },
          ),
        );
      },
    );
  }
}
