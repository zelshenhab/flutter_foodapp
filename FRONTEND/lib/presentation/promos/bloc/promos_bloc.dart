import 'package:flutter_bloc/flutter_bloc.dart';
import 'promos_event.dart';
import 'promos_state.dart';
import '../data/mock_promos_repo.dart';

class PromosBloc extends Bloc<PromosEvent, PromosState> {
  PromosBloc() : super(const PromosState(loading: true)) {
    on<PromosStarted>(_load);
    on<PromosRefreshed>(_load);
  }

  Future<void> _load(PromosEvent e, Emitter<PromosState> emit) async {
    try {
      emit(state.copyWith(loading: true, error: null));
      await Future.delayed(const Duration(milliseconds: 250)); // إحساس بالتحميل
      final list = MockPromosRepo.fetchActive();
      emit(state.copyWith(loading: false, promos: list));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Ошибка загрузки акций'));
    }
  }
}
