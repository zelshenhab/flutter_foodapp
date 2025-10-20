import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repos/promos_repo.dart';
import 'promos_event.dart';
import 'promos_state.dart';

class PromosBloc extends Bloc<PromosEvent, PromosState> {
  final PromosRepo repo;

  // Positional (الأصلي)
  PromosBloc(this.repo) : super(const PromosState()) {
    on<PromosLoaded>(_onLoaded);
    on<PromoAdded>(_onAdd);
    on<PromoUpdated>(_onUpdate);
    on<PromoDeleted>(_onDelete);
    on<PromoToggled>(_onToggle);
  }

  // ✅ Named
  PromosBloc.withRepo({required PromosRepo repo}) : this(repo);

  Future<void> _onLoaded(PromosLoaded e, Emitter<PromosState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await repo.fetchPromos();
      emit(state.copyWith(loading: false, data: list));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Не удалось загрузить акции'));
    }
  }

  Future<void> _onAdd(PromoAdded e, Emitter<PromosState> emit) async {
    final ok = await repo.addPromo(e.promo);
    if (!ok) return emit(state.copyWith(error: 'Ошибка при добавлении'));
    add(const PromosLoaded());
  }

  Future<void> _onUpdate(PromoUpdated e, Emitter<PromosState> emit) async {
    final ok = await repo.updatePromo(e.promo);
    if (!ok) return emit(state.copyWith(error: 'Ошибка при обновлении'));
    add(const PromosLoaded());
  }

  Future<void> _onDelete(PromoDeleted e, Emitter<PromosState> emit) async {
    final ok = await repo.deletePromo(e.id);
    if (!ok) return emit(state.copyWith(error: 'Ошибка при удалении'));
    add(const PromosLoaded());
  }

  Future<void> _onToggle(PromoToggled e, Emitter<PromosState> emit) async {
    final ok = await repo.toggleActive(e.id, e.active);
    if (!ok) return emit(state.copyWith(error: 'Ошибка при смене статуса'));
    add(const PromosLoaded());
  }
}
