import 'package:equatable/equatable.dart';
import '../../../data/repos/orders_repo.dart';

class OrdersState extends Equatable {
  final bool loading;
  final List<AdminOrder> data;
  final String filter;
  final String? error;

  const OrdersState({
    this.loading = false,
    this.data = const [],
    this.filter = 'all',
    this.error,
  });

  OrdersState copyWith({
    bool? loading,
    List<AdminOrder>? data,
    String? filter,
    String? error,
  }) {
    return OrdersState(
      loading: loading ?? this.loading,
      data: data ?? this.data,
      filter: filter ?? this.filter,
      error: error,
    );
  }

  List<AdminOrder> get filtered =>
      filter == 'all' ? data : data.where((o) => o.status == filter).toList();

  @override
  List<Object?> get props => [loading, data, filter, error];
}
