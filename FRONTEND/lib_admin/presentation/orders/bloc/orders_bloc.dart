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

  // تحميل الطلبات
  Future<void> _onLoaded(OrdersLoaded e, Emitter<OrdersState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await repo.fetchOrders();
      emit(state.copyWith(loading: false, data: list));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Не удалось загрузить заказы'));
    }
  }

  // تغيير الفلتر
  Future<void> _onFilter(
    OrdersFilterChanged e,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(filter: e.filter));
  }

  // تغيير حالة الطلب (مع Optimistic Update + Rollback عند الفشل)
  Future<void> _onStatus(
    OrderStatusChanged e,
    Emitter<OrdersState> emit,
  ) async {
    // لو الحالة الجديدة هي نفسها الحالية — لا تعمل شيء
    final current = state.data.firstWhere(
      (o) => o.id == e.orderId,
      orElse: () => state.data.isNotEmpty ? state.data.first : null as dynamic,
    );
    if (current != null && current.status == e.status) return;

    // احتفظ بنسخة قبل التعديل (للـ rollback)
    final prevData = state.data;

    // تحديث متفائل
    final optimistic = state.data
        .map((o) => o.id == e.orderId ? o.copyWith(status: e.status) : o)
        .toList();

    emit(state.copyWith(data: optimistic, error: null));

    try {
      final ok = await repo.updateOrderStatus(e.orderId, e.status);
      if (!ok) {
        // رجّع الحالة القديمة لو السيرفر رفض
        emit(
          state.copyWith(data: prevData, error: 'Не удалось обновить статус'),
        );
      }
    } catch (_) {
      // في حال الاستثناء — Rollback + رسالة
      emit(state.copyWith(data: prevData, error: 'Не удалось обновить статус'));
    }
  }
}
