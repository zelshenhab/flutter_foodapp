import 'package:equatable/equatable.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();
  @override
  List<Object?> get props => [];
}

class OrdersLoaded extends OrdersEvent {
  const OrdersLoaded();
}

class OrdersFilterChanged extends OrdersEvent {
  final String filter;
  const OrdersFilterChanged(this.filter);
  @override
  List<Object?> get props => [filter];
}

class OrderStatusChanged extends OrdersEvent {
  final int orderId;
  final String status;
  const OrderStatusChanged(this.orderId, this.status);

  @override
  List<Object?> get props => [orderId, status];
}

class OrdersErrorDismissed extends OrdersEvent {
  const OrdersErrorDismissed();
}