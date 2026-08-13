import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repos/analytics_repo.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepo repo;

  AnalyticsBloc(this.repo) : super(const AnalyticsState()) {
    on<AnalyticsLoad>(_onLoad);
  }

  Future<void> _onLoad(
    AnalyticsLoad e,
    Emitter<AnalyticsState> emit,
  ) async {
    debugPrint("🚀 AnalyticsLoad TRIGGERED"); // 👈 ADD HERE

    emit(state.copyWith(loading: true, error: null));

    try {
      final results = await Future.wait([
          repo.dailyRevenue(),
          repo.ordersByStatus(),
          repo.bestSelling(),
          repo.summary(),
        ]);

      debugPrint("📊 BLOC SUMMARY: ${results[3]}"); // 👈 ADD HERE


      emit(state.copyWith(
        loading: false,
        dailyRevenue: results[0] as List<dynamic>,
        ordersByStatus: results[1] as Map<String, dynamic>,
        bestSelling: results[2] as List<dynamic>,
        summary: results[3] as Map<String, dynamic>,
      ));
    } catch (err) {
      debugPrint("❌ BLOC ERROR: $err"); // 👈 ADD HERE

      emit(
        state.copyWith(
          loading: false,
          error: 'Ошибка загрузки аналитики',
        ),
      );
    }
  }
}