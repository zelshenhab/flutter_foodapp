import 'package:equatable/equatable.dart';
import '../models/order.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();
  @override
  List<Object?> get props => [];
}

class OrdersStarted extends OrdersEvent {}
class OrdersRefreshed extends OrdersEvent {}

/// يضغطها العميل عندما يستلم الطلب الجاهز من الكاشير
class OrderPickupConfirmed extends OrdersEvent {
  final String orderId;
  const OrderPickupConfirmed(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

/// (اختياري) تحديث حالة معين من الداشبورد الريلتايم
class OrderStatusPatched extends OrdersEvent {
  final String orderId;
  final OrderStatus status;
  const OrderStatusPatched(this.orderId, this.status);
  @override
  List<Object?> get props => [orderId, status];
}
