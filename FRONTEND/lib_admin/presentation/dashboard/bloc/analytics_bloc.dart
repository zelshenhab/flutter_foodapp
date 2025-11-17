import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repos/analytics_repo.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepo repo;

  AnalyticsBloc(this.repo) : super(const AnalyticsState()) {
    on<AnalyticsLoad>(_onLoad);
  }

  Future<void> _onLoad(AnalyticsLoad e, Emitter<AnalyticsState> emit) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final daily = await repo.dailyRevenue();
      final status = await repo.ordersByStatus();
      final best = await repo.bestSelling();
      final summary = await repo.summary();

      emit(state.copyWith(
        loading: false,
        dailyRevenue: daily,
        ordersByStatus: status,
        bestSelling: best,
        summary: summary,
      ));
    } catch (err) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Ошибка загрузки аналитики',
        ),
      );
    }
  }
}
