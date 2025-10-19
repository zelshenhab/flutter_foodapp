import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repos/orders_repo.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersRepo repo;

  OrdersBloc(this.repo) : super(const OrdersState()) {
    on<OrdersLoaded>(_onLoaded);
    on<OrdersFilterChanged>(_onFilter);
    on<OrderStatusChanged>(_onStatus);
  }

  Future<void> _onLoaded(OrdersLoaded e, Emitter<OrdersState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await repo.fetchOrders();
      emit(state.copyWith(loading: false, data: list));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Не удалось загрузить заказы'));
    }
  }

  Future<void> _onFilter(
    OrdersFilterChanged e,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(filter: e.filter));
  }

  Future<void> _onStatus(
    OrderStatusChanged e,
    Emitter<OrdersState> emit,
  ) async {
    // ابحث بأمان (من غير null-cast)
    final currentIndex = state.data.indexWhere((o) => o.id == e.orderId);
    if (currentIndex == -1) return;
    final current = state.data[currentIndex];
    if (current.status == e.status) return;

    // خزّن نسخة قبل التحديث (rollback)
    final prevData = List<AdminOrder>.from(state.data);

    // تحديث متفائل
    final optimistic = List<AdminOrder>.from(state.data);
    optimistic[currentIndex] = current.copyWith(status: e.status);
    emit(state.copyWith(data: optimistic, error: null));

    try {
      final ok = await repo.updateOrderStatus(e.orderId, e.status);
      if (!ok) {
        emit(state.copyWith(data: prevData, error: 'Не удалось обновить статус'));
      }
    } catch (_) {
      emit(state.copyWith(data: prevData, error: 'Не удалось обновить статус'));
    }
  }
}
