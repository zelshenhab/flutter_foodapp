import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repos/orders_repository.dart';
import '../models/order_model.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersRepository repo;

  OrdersBloc({OrdersRepository? repo})
      : repo = repo ?? const OrdersRepository(),
        super(const OrdersState(loading: true)) {
    on<OrdersStarted>(_load);
    on<OrdersRefreshed>(_refresh);
    on<OrderPickupConfirmed>(_onPickupConfirmed);
    on<OrderStatusPatched>(_onStatusPatched);
  }

  /// 🔹 Initial load of user's orders
  Future<void> _load(OrdersEvent e, Emitter<OrdersState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final orders = await repo.getUserOrders();
      emit(state.copyWith(loading: false, orders: orders));
    } catch (err) {
      emit(state.copyWith(
        loading: false,
        error: 'Ошибка загрузки заказов: ${err.toString()}',
      ));
    }
  }

  /// 🔁 Manual refresh
  Future<void> _refresh(OrdersRefreshed e, Emitter<OrdersState> emit) async {
    try {
      final orders = await repo.getUserOrders();
      emit(state.copyWith(orders: orders, error: null));
    } catch (err) {
      emit(state.copyWith(error: 'Ошибка обновления заказов'));
    }
  }

  /// 🧾 Customer confirms pickup (status ready → completed)
  Future<void> _onPickupConfirmed(
      OrderPickupConfirmed e, Emitter<OrdersState> emit) async {
    final updated = state.orders.map((o) {
      if (o.id == e.orderId) {
        // Create a new OrderModel with updated status
        return OrderModel(
          id: o.id,
          userId: o.userId,
          status: 'completed',
          paymentMethod: o.paymentMethod,
          paymentStatus: o.paymentStatus,
          subtotal: o.subtotal,
          discount: o.discount,
          deliveryFee: o.deliveryFee,
          total: o.total,
          addressText: o.addressText,
          promoCode: o.promoCode,
          notes: o.notes,
          createdAt: o.createdAt,
        );
      }
      return o;
    }).toList();

    emit(state.copyWith(orders: updated));
  }

  /// ⚡ Realtime or external status update (optional)
  void _onStatusPatched(OrderStatusPatched e, Emitter<OrdersState> emit) {
    final updated = state.orders.map((o) {
      if (o.id == e.orderId) {
        return OrderModel(
          id: o.id,
          userId: o.userId,
          status: e.status,
          paymentMethod: o.paymentMethod,
          paymentStatus: o.paymentStatus,
          subtotal: o.subtotal,
          discount: o.discount,
          deliveryFee: o.deliveryFee,
          total: o.total,
          addressText: o.addressText,
          promoCode: o.promoCode,
          notes: o.notes,
          createdAt: o.createdAt,
        );
      }
      return o;
    }).toList();

    emit(state.copyWith(orders: updated));
  }
}
