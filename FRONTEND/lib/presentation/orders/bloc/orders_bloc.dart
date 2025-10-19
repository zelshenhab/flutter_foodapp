import 'package:flutter_bloc/flutter_bloc.dart';
import 'orders_event.dart';
import 'orders_state.dart';
import '../data/mock_orders_repo.dart';
import '../models/order.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc() : super(const OrdersState(loading: true)) {
    on<OrdersStarted>(_load);
    on<OrdersRefreshed>(_load);
    on<OrderPickupConfirmed>(_onPickupConfirmed);
    on<OrderStatusPatched>(_onPatched);
  }

  Future<void> _load(OrdersEvent e, Emitter<OrdersState> emit) async {
    try {
      emit(state.copyWith(loading: true, error: null));
      await Future.delayed(const Duration(milliseconds: 250));
      final data = MockOrdersRepo.fetchMyOrders();
      emit(state.copyWith(loading: false, orders: data));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Ошибка загрузки заказов'));
    }
  }

  /// العميل يؤكّد أنه استلم الطلب (ready -> completed)
  Future<void> _onPickupConfirmed(
      OrderPickupConfirmed e, Emitter<OrdersState> emit) async {
    final updated = state.orders.map((o) {
      if (o.id == e.orderId) {
        return o.copyWith(status: OrderStatus.completed);
      }
      return o;
    }).toList();
    emit(state.copyWith(orders: updated));
  }

  /// (اختياري) لو وصلك تحديث حالة من سوكِت/ريال تايم
  void _onPatched(OrderStatusPatched e, Emitter<OrdersState> emit) {
    final updated = state.orders.map((o) {
      if (o.id == e.orderId) {
        return o.copyWith(status: e.status);
      }
      return o;
    }).toList();
    emit(state.copyWith(orders: updated));
  }
}
