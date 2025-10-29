import 'package:equatable/equatable.dart';
import '../models/order_model.dart';

class OrdersState extends Equatable {
  final bool loading;
  final String? error;
  final List<OrderModel> orders;

  const OrdersState({
    this.loading = false,
    this.error,
    this.orders = const [],
  });

  OrdersState copyWith({
    bool? loading,
    String? error,
    List<OrderModel>? orders,
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
