import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/l10n/locale_cubit.dart';
import 'package:flutter_foodapp/presentation/menu/models/menu_item.dart';
import '../models/category.dart';
import 'menu_event.dart';
import 'menu_state.dart';

import '../../../core/api_client.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc() : super(const MenuState()) {
    on<MenuStarted>(_onStarted);
    on<MenuCategorySelected>(_onCategorySelected);
    on<MenuRefreshed>(_onRefreshed);
    on<MenuSearchChanged>(_onSearchChanged);
  }

  List<MenuItemModel> _allItems = const [];

  // ================= START =================

  Future<void> _onStarted(MenuStarted event, Emitter<MenuState> emit) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final catsRes = await dio.get('/menu/categories');

      final catsList = (catsRes.data['data'] as List)
          .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      final itemsRes = await dio.get('/menu/items');

      _allItems = (itemsRes.data['data'] as List)
          .map((e) => MenuItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      final first = catsList.isNotEmpty ? catsList.first.id : null;

      final filtered = _applyFilters(
        categoryId: first,
        query: '',
      );

      emit(
        state.copyWith(
          loading: false,
          categories: catsList,
          selectedCategoryId: first,
          items: filtered,
        ),
      );
    } catch (_) {
      emit(state.copyWith(
        loading: false,
        error: LocaleCubit.l10n.menuLoadFailed,
      ));
    }
  }

  // ================= CATEGORY =================

  Future<void> _onCategorySelected(
      MenuCategorySelected e, Emitter<MenuState> emit) async {
    emit(state.copyWith(
      loading: true,
      selectedCategoryId: e.categoryId,
      error: null,
    ));

    final filtered = _applyFilters(
      categoryId: e.categoryId,
      query: state.searchQuery,
    );

    emit(state.copyWith(
      loading: false,
      items: filtered,
    ));
  }

  // ================= SEARCH =================

  void _onSearchChanged(MenuSearchChanged e, Emitter<MenuState> emit) {
    final filtered = _applyFilters(
      categoryId: state.selectedCategoryId,
      query: e.query,
    );

    emit(state.copyWith(
      searchQuery: e.query,
      items: filtered,
    ));
  }

  // ================= REFRESH =================

  Future<void> _onRefreshed(MenuRefreshed e, Emitter<MenuState> emit) async {
    final id = state.selectedCategoryId;

    emit(state.copyWith(loading: true, error: null));

    try {
      final itemsRes = await dio.get('/menu/items');

      _allItems = (itemsRes.data['data'] as List)
          .map((e) => MenuItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      final filtered = _applyFilters(
        categoryId: id,
        query: state.searchQuery,
      );

      emit(state.copyWith(
        loading: false,
        items: filtered,
      ));
    } catch (_) {
      emit(state.copyWith(
        loading: false,
        error: LocaleCubit.l10n.dishesRefreshFailed,
      ));
    }
  }

  // ================= FILTER ENGINE =================

  List<MenuItemModel> _applyFilters({
    String? categoryId,
    String query = '',
  }) {
    final q = query.toLowerCase();

    return _allItems.where((item) {
      final categoryMatch =
          categoryId == null || item.categoryId == categoryId;

      final name = item.name.toLowerCase();
      final desc = (item.description ?? '').toLowerCase();

      final searchMatch =
          q.isEmpty || name.contains(q) || desc.contains(q);

      return categoryMatch && searchMatch;
    }).toList();
  }
}