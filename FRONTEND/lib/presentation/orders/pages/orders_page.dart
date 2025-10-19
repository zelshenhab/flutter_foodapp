import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../orders/bloc/orders_bloc.dart';
import '../../orders/bloc/orders_event.dart';
import '../../orders/bloc/orders_state.dart';
import '../../orders/widgets/order_card.dart';
import 'order_details_page.dart';

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
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.error!),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<OrdersBloc>().add(OrdersStarted()),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              );
            }
            if (state.orders.isEmpty) {
              return const Center(child: Text('Заказов пока нет'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<OrdersBloc>().add(OrdersRefreshed());
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.orders.length,
                itemBuilder: (context, i) {
                  final order = state.orders[i];
                  return OrderCard(
                    order: order,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context
                                .read<OrdersBloc>(), // نمرّر نفس الـ bloc
                            child: OrderDetailsPage(order: order),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
