import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/presentation/menu/models/menu_item.dart';
import 'menu_event.dart';
import 'menu_state.dart';
import '../data/mock_menu_repo.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc() : super(const MenuState()) {
    on<MenuStarted>(_onStarted);
    on<MenuCategorySelected>(_onCategorySelected);
    on<MenuRefreshed>(_onRefreshed);
  }

  Future<void> _onStarted(MenuStarted event, Emitter<MenuState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final cats = MockMenuRepo.getCategories();
      final first = cats.isNotEmpty ? cats.first.id : null;
      final items = first != null
          ? MockMenuRepo.getItemsByCategory(first)
          : <MenuItemEntity>[];
      emit(
        state.copyWith(
          loading: false,
          categories: cats,
          selectedCategoryId: first,
          items: items,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onCategorySelected(
    MenuCategorySelected e,
    Emitter<MenuState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        selectedCategoryId: e.categoryId,
        error: null,
      ),
    );
    final items = MockMenuRepo.getItemsByCategory(e.categoryId);
    emit(state.copyWith(loading: false, items: items));
  }

  Future<void> _onRefreshed(MenuRefreshed e, Emitter<MenuState> emit) async {
    final id = state.selectedCategoryId;
    if (id == null) return;
    emit(state.copyWith(loading: true, error: null));
    final items = MockMenuRepo.getItemsByCategory(id);
    emit(state.copyWith(loading: false, items: items));
  }
}
