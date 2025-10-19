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

  Future<void> _onLoaded(
    MenuAdminLoaded e,
    Emitter<MenuAdminState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final cats = await repo.fetchCategories();
      final firstId = cats.isNotEmpty ? cats.first.id : '';
      final items = firstId.isEmpty
          ? <AdminDish>[]
          : await repo.fetchDishesByCategory(firstId);

      emit(state.copyWith(
        loading: false,
        categories: cats,
        selectedCategoryId: firstId,
        items: items,
        error: null,
      ));
    } catch (_) {
      emit(state.copyWith(
        loading: false,
        error: 'Не удалось загрузить меню',
      ));
    }
  }

  Future<void> _onCategory(
    MenuCategoryChanged e,
    Emitter<MenuAdminState> emit,
  ) async {
    if (e.categoryId.isEmpty) {
      emit(state.copyWith(selectedCategoryId: '', items: const []));
      return;
    }
    emit(state.copyWith(
      loading: true,
      selectedCategoryId: e.categoryId,
      error: null,
    ));
    try {
      final items = await repo.fetchDishesByCategory(e.categoryId);
      emit(state.copyWith(loading: false, items: items));
    } catch (_) {
      emit(state.copyWith(
        loading: false,
        error: 'Не удалось загрузить блюда',
      ));
    }
  }

  Future<void> _onAdd(
    MenuItemAdded e,
    Emitter<MenuAdminState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final ok = await repo.addDish(e.dish);
      if (!ok) {
        emit(state.copyWith(
          loading: false,
          error: 'Ошибка при добавлении блюда',
        ));
        return;
      }
      // إعادة تحميل عناصر الفئة الحالية بدل add(Event) لتفادي مشاكل التداخل
      final items = await repo.fetchDishesByCategory(state.selectedCategoryId);
      emit(state.copyWith(loading: false, items: items));
    } catch (_) {
      emit(state.copyWith(
        loading: false,
        error: 'Ошибка при добавлении блюда',
      ));
    }
  }

  Future<void> _onUpdate(
    MenuItemUpdated e,
    Emitter<MenuAdminState> emit,
  ) async {
    // Optimistic update محليًا
    final optimistic = state.items
        .map((d) => d.id == e.dish.id ? e.dish : d)
        .toList();
    emit(state.copyWith(items: optimistic, error: null));

    try {
      final ok = await repo.updateDish(e.dish);
      if (!ok) {
        // Rollback
        final refreshed =
            await repo.fetchDishesByCategory(state.selectedCategoryId);
        emit(state.copyWith(
          items: refreshed,
          error: 'Ошибка при обновлении блюда',
        ));
      }
    } catch (_) {
      // Rollback
      final refreshed =
          await repo.fetchDishesByCategory(state.selectedCategoryId);
      emit(state.copyWith(
        items: refreshed,
        error: 'Ошибка при обновлении блюда',
      ));
    }
  }

  Future<void> _onDelete(
    MenuItemDeleted e,
    Emitter<MenuAdminState> emit,
  ) async {
    // Optimistic: شيل الصنف محليًا
    final before = state.items;
    final after = before.where((d) => d.id != e.dishId).toList();
    emit(state.copyWith(items: after, error: null));

    try {
      final ok = await repo.deleteDish(e.dishId);
      if (!ok) {
        emit(state.copyWith(
          items: before,
          error: 'Ошибка при удалении блюда',
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        items: before,
        error: 'Ошибка при удалении блюда',
      ));
    }
  }
}
