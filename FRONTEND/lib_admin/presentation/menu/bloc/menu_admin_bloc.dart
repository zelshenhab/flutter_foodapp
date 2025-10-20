// lib_admin/presentation/menu/bloc/menu_admin_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/presentation/menu/models/menu_item.dart';

import '../../../data/repos/menu_repo_supabase.dart';
import 'menu_admin_event.dart';
import 'menu_admin_state.dart';

class MenuAdminBloc extends Bloc<MenuAdminEvent, MenuAdminState> {
  final MenuRepoSupabase repo;

  MenuAdminBloc(this.repo) : super(const MenuAdminState()) {
    on<MenuAdminLoaded>(_onLoaded);
    on<MenuCategoryChanged>(_onCategory);
    on<MenuItemAdded>(_onAdd);
    on<MenuItemUpdated>(_onUpdate);
    on<MenuItemDeleted>(_onDelete);
  }

  MenuAdminBloc.withSupabase({required MenuRepoSupabase repo}) : this(repo);

  Future<void> _onLoaded(
    MenuAdminLoaded e,
    Emitter<MenuAdminState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final cats = await repo.fetchCategories();
      final firstId = cats.isNotEmpty ? cats.first.id : '';
      final items = firstId.isEmpty
          ? <MenuItemModel>[]
          : await repo.fetchDishesByCategory(firstId);
      emit(
        state.copyWith(
          loading: false,
          categories: cats,
          selectedCategoryId: firstId,
          items: items,
        ),
      );
    } catch (err) {
      // ignore: avoid_print
      print('ADMIN MENU LOAD ERROR: $err');
      emit(state.copyWith(loading: false, error: '$err'));
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
    emit(
      state.copyWith(
        loading: true,
        selectedCategoryId: e.categoryId,
        error: null,
      ),
    );
    try {
      final items = await repo.fetchDishesByCategory(e.categoryId);
      emit(state.copyWith(loading: false, items: items));
    } catch (err) {
      // ignore: avoid_print
      print('ADMIN DISHES LOAD ERROR: $err');
      emit(state.copyWith(loading: false, error: '$err'));
    }
  }

  Future<void> _onAdd(MenuItemAdded e, Emitter<MenuAdminState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await repo.addDish(e.dish);
      final items = await repo.fetchDishesByCategory(state.selectedCategoryId);
      emit(state.copyWith(loading: false, items: items));
    } catch (err) {
      // ignore: avoid_print
      print('ADMIN DISH ADD ERROR: $err');
      emit(state.copyWith(loading: false, error: '$err'));
    }
  }

  Future<void> _onUpdate(
    MenuItemUpdated e,
    Emitter<MenuAdminState> emit,
  ) async {
    final optimistic = state.items
        .map((d) => d.id == e.dish.id ? e.dish : d)
        .toList();
    emit(state.copyWith(items: optimistic, error: null));
    try {
      await repo.updateDish(e.dish);
    } catch (err) {
      final refreshed = await repo.fetchDishesByCategory(
        state.selectedCategoryId,
      );
      // ignore: avoid_print
      print('ADMIN DISH UPDATE ERROR: $err');
      emit(state.copyWith(items: refreshed, error: '$err'));
    }
  }

  Future<void> _onDelete(
    MenuItemDeleted e,
    Emitter<MenuAdminState> emit,
  ) async {
    final before = state.items;
    final after = before.where((d) => d.id != e.dish.id).toList();
    emit(state.copyWith(items: after, error: null)); // optimistic
    try {
      await repo.deleteDish(e.dish);
    } catch (err) {
      final refreshed = await repo.fetchDishesByCategory(
        state.selectedCategoryId,
      );
      // ignore: avoid_print
      print('ADMIN DISH DELETE ERROR: $err');
      emit(state.copyWith(items: refreshed, error: '$err'));
    }
  }
}
