import 'package:equatable/equatable.dart';
import '../models/order.dart';

class OrdersState extends Equatable {
  final bool loading;
  final String? error;
  final List<OrderEntity> orders;

  const OrdersState({
    this.loading = false,
    this.error,
    this.orders = const [],
  });

  OrdersState copyWith({
    bool? loading,
    String? error,
    List<OrderEntity>? orders,
  }) {
    return OrdersState(
      loading: loading ?? this.loading,
      error: error,
      orders: orders ?? this.orders,
    );
  }

  @override
  List<Object?> get props => [loading, error, orders];
}
