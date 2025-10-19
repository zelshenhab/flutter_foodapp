import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repos/menu_repo.dart';
import 'menu_admin_event.dart';
import 'menu_admin_state.dart';

class MenuAdminBloc extends Bloc<MenuAdminEvent, MenuAdminState> {
  final MenuRepo repo;
  MenuAdminBloc(this.repo) : super(const MenuAdminState()) {
    on<MenuAdminLoaded>(_onLoaded);
    on<MenuCategoryChanged>(_onCategory);
    on<MenuItemAdded>(_onAdd);
    on<MenuItemUpdated>(_onUpdate);
    on<MenuItemDeleted>(_onDelete);
  }

  Future<void> _onLoaded(MenuAdminLoaded e, Emitter<MenuAdminState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final cats = await repo.fetchCategories();
      final firstId = cats.isNotEmpty ? cats.first.id : '';
      final items = firstId.isEmpty ? <AdminDish>[] : await repo.fetchDishesByCategory(firstId);
      emit(state.copyWith(
        loading: false,
        categories: cats,
        selectedCategoryId: firstId,
        items: items,
      ));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Не удалось загрузить меню'));
    }
  }

  Future<void> _onCategory(MenuCategoryChanged e, Emitter<MenuAdminState> emit) async {
    emit(state.copyWith(loading: true, selectedCategoryId: e.categoryId, error: null));
    final items = await repo.fetchDishesByCategory(e.categoryId);
    emit(state.copyWith(loading: false, items: items));
  }

  Future<void> _onAdd(MenuItemAdded e, Emitter<MenuAdminState> emit) async {
    final ok = await repo.addDish(e.dish);
    if (!ok) return emit(state.copyWith(error: 'Ошибка при добавлении блюда'));
    add(MenuCategoryChanged(state.selectedCategoryId));
  }

  Future<void> _onUpdate(MenuItemUpdated e, Emitter<MenuAdminState> emit) async {
    final ok = await repo.updateDish(e.dish);
    if (!ok) return emit(state.copyWith(error: 'Ошибка при обновлении блюда'));
    add(MenuCategoryChanged(state.selectedCategoryId));
  }

  Future<void> _onDelete(MenuItemDeleted e, Emitter<MenuAdminState> emit) async {
    final ok = await repo.deleteDish(e.dishId);
    if (!ok) return emit(state.copyWith(error: 'Ошибка при удалении блюда'));
    add(MenuCategoryChanged(state.selectedCategoryId));
  }
}
