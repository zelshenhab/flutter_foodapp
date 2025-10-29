import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';
import '../widgets/order_card.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrdersBloc()..add(OrdersStarted()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Мои заказы')),
        body: BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(child: Text(state.error!));
            }
            if (state.orders.isEmpty) {
              return const Center(child: Text('У вас пока нет заказов'));
            }

            return ListView.separated(
              itemCount: state.orders.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return OrderCard(order: order);
              },
            );
          },
        ),
      ),
    );
  }
}
