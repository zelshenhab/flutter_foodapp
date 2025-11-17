import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repos/menu_repo.dart';
import 'menu_admin_event.dart';
import 'menu_admin_state.dart';

class MenuAdminBloc extends Bloc<MenuAdminEvent, MenuAdminState> {
  final MenuRepo repo;

  MenuAdminBloc({required this.repo}) : super(const MenuAdminState()) {
    on<MenuAdminLoaded>(_onLoaded);
    on<MenuCategoryChanged>(_onCategoryChanged);
    on<MenuItemAdded>(_onAddItem);
    on<MenuItemUpdated>(_onUpdateItem);
    on<MenuItemDeleted>(_onDeleteItem);
  }

  /* ──────────────────────────────────────────────
     1) LOAD all (categories + items)
     ────────────────────────────────────────────── */
  Future<void> _onLoaded(
    MenuAdminLoaded event,
    Emitter<MenuAdminState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      // Cast to List<Map<String, dynamic>>
      final categories = List<Map<String, dynamic>>.from(
        await repo.fetchCategories(),
      );
      final allItems = List<Map<String, dynamic>>.from(
        await repo.fetchMenu(),
      );

      final selectedCategoryId =
          categories.isNotEmpty ? categories.first["id"].toString() : "";

      final filtered = allItems
          .where((i) => i["categoryId"].toString() == selectedCategoryId)
          .toList();

      emit(
        state.copyWith(
          loading: false,
          categories: categories,
          selectedCategoryId: selectedCategoryId,
          items: filtered,
        ),
      );
    } catch (err) {
      debugPrint("ADMIN MENU LOAD ERROR: $err");
      emit(state.copyWith(loading: false, error: "$err"));
    }
  }

  /* ──────────────────────────────────────────────
     2) CATEGORY changed
     ────────────────────────────────────────────── */
  Future<void> _onCategoryChanged(
    MenuCategoryChanged event,
    Emitter<MenuAdminState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        selectedCategoryId: event.categoryId,
        error: null,
      ),
    );

    try {
      final allItems = List<Map<String, dynamic>>.from(
        await repo.fetchMenu(),
      );

      final filtered = allItems
          .where((i) => i["categoryId"].toString() == event.categoryId)
          .toList();

      emit(
        state.copyWith(
          loading: false,
          items: filtered,
        ),
      );
    } catch (err) {
      debugPrint("CATEGORY LOAD ERROR: $err");
      emit(state.copyWith(loading: false, error: "$err"));
    }
  }

  /* ──────────────────────────────────────────────
     3) ADD item
     ────────────────────────────────────────────── */
  Future<void> _onAddItem(
    MenuItemAdded event,
    Emitter<MenuAdminState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      await repo.createMenuItem(event.dish);
      add(const MenuAdminLoaded()); // reload all
    } catch (err) {
      debugPrint("ADD ITEM ERROR: $err");
      emit(state.copyWith(loading: false, error: "$err"));
    }
  }

  /* ──────────────────────────────────────────────
     4) UPDATE item
     ────────────────────────────────────────────── */
  Future<void> _onUpdateItem(
    MenuItemUpdated event,
    Emitter<MenuAdminState> emit,
  ) async {
    final id = event.dish["id"];

    // Optimistic UI update
    final optimistic = state.items.map((item) {
      return item["id"] == id ? event.dish : item;
    }).toList();

    emit(state.copyWith(items: optimistic));

    try {
      await repo.updateItem(id, event.dish);
    } catch (err) {
      debugPrint("UPDATE ERROR: $err");
      add(const MenuAdminLoaded());
      emit(state.copyWith(error: "$err"));
    }
  }

  /* ──────────────────────────────────────────────
     5) DELETE item
     ────────────────────────────────────────────── */
  Future<void> _onDeleteItem(
    MenuItemDeleted event,
    Emitter<MenuAdminState> emit,
  ) async {
    final id = event.dish["id"];

    // Optimistic removal
    final optimistic =
        state.items.where((i) => i["id"] != id).toList();

    emit(state.copyWith(items: optimistic));

    try {
      await repo.deleteMenuItem(id);
    } catch (err) {
      debugPrint("DELETE ERROR: $err");
      add(const MenuAdminLoaded());
      emit(state.copyWith(error: "$err"));
    }
  }
}
