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
    on<OrdersErrorDismissed>(_onErrorDismissed);
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
    final oldStatus = oldList[index].status;
    
    // Optimistic update
    List<AdminOrder> optimistic = List.from(state.data);
    optimistic[index] = optimistic[index].copyWith(status: e.status);
    emit(state.copyWith(data: optimistic, error: null));

    try {
      final ok = await repo.updateOrderStatus(e.orderId, e.status);
      if (ok) {
        // Success - keep the optimistic state, just clear any errors
        emit(state.copyWith(data: optimistic, error: null));
      } else {
        // Revert on failure
        optimistic[index] = optimistic[index].copyWith(status: oldStatus);
        emit(state.copyWith(
          data: oldList,
          error: "Не удалось обновить статус",
        ));
      }
    } catch (err) {
      // Revert on error
      optimistic[index] = optimistic[index].copyWith(status: oldStatus);
      emit(state.copyWith(
        data: oldList,
        error: "Не удалось обновить статус",
      ));
    }
  }

  void _onErrorDismissed(OrdersErrorDismissed e, Emitter<OrdersState> emit) {
    emit(state.copyWith(error: null));
  }
}