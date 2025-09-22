import 'package:flutter_bloc/flutter_bloc.dart';
import 'orders_event.dart';
import 'orders_state.dart';
import '../data/mock_orders_repo.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc() : super(const OrdersState(loading: true)) {
    on<OrdersStarted>(_load);
    on<OrdersRefreshed>(_load);
  }

  Future<void> _load(OrdersEvent e, Emitter<OrdersState> emit) async {
    try {
      emit(state.copyWith(loading: true, error: null));
      await Future.delayed(const Duration(milliseconds: 250));
      final data = MockOrdersRepo.fetchMyOrders();
      emit(state.copyWith(loading: false, orders: data));
    } catch (err) {
      emit(state.copyWith(loading: false, error: 'Ошибка загрузки заказов'));
    }
  }
}
