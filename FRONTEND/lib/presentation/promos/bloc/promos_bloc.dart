// lib/presentation/promos/bloc/promos_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/presentation/promos/data/mock_promos_repo.dart';
import 'promos_event.dart';
import 'promos_state.dart';

class PromosBloc extends Bloc<PromosEvent, PromosState> {
  PromosBloc() : super(const PromosState(loading: true)) {
    on<PromosStarted>(_load);
    on<PromosRefreshed>(_load);
  }

  Future<void> _load(PromosEvent e, Emitter<PromosState> emit) async {
    try {
      emit(state.copyWith(loading: true, error: null));
      
      // ✅ Use REAL repo instead of mock
      final list = await RealPromosRepo.fetchActive();
      
      emit(state.copyWith(loading: false, promos: list));
    } catch (error) {
      print('Error loading promos: $error');
      emit(state.copyWith(
        loading: false, 
        error: 'Ошибка загрузки акций',
        promos: [], // Empty list on error
      ));
    }
  }
}