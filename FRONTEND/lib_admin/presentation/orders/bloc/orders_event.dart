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
  final String filter; // all/pending/preparing/ready/completed/cancelled
  const OrdersFilterChanged(this.filter);
  @override
  List<Object?> get props => [filter];
}

class OrderStatusChanged extends OrdersEvent {
  final String orderId;
  final String status;
  const OrderStatusChanged(this.orderId, this.status);
  @override
  List<Object?> get props => [orderId, status];
}
