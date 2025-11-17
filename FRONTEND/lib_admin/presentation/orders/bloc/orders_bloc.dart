import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/orders_models.dart';
import '../../../data/repos/orders_repo.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersRepo repo;

  OrdersBloc(this.repo) : super(const OrdersState()) {
    on<OrdersLoaded>(_onLoaded);
    on<OrdersFilterChanged>(_onFilter);
    on<OrderStatusChanged>(_onStatusChanged);
  }

  Future<void> _onLoaded(
    OrdersLoaded e,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final orders = await repo.fetchOrders();
      emit(state.copyWith(loading: false, data: orders));
    } catch (err) {
      emit(state.copyWith(
        loading: false,
        error: "Не удалось загрузить заказы",
      ));
    }
  }

  Future<void> _onFilter(
    OrdersFilterChanged e,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(filter: e.filter));
  }

  Future<void> _onStatusChanged(
    OrderStatusChanged e,
    Emitter<OrdersState> emit,
  ) async {
    final index = state.data.indexWhere((o) => o.id == e.orderId);
    if (index == -1) return;

    final oldList = List<AdminOrder>.from(state.data);
    final updated = oldList[index].copyWith(status: e.status);

    // optimistic update
    List<AdminOrder> optimistic = List.from(state.data);
    optimistic[index] = updated;
    emit(state.copyWith(data: optimistic));

    try {
      final ok = await repo.updateOrderStatus(e.orderId, e.status);
      if (!ok) {
        emit(state.copyWith(
          data: oldList,
          error: "Не удалось обновить статус",
        ));
      }
    } catch (err) {
      emit(state.copyWith(
        data: oldList,
        error: "Не удалось обновить статус",
      ));
    }
  }
}
