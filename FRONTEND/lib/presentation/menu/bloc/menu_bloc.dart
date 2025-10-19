import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/presentation/menu/models/menu_item.dart';
import '../models/category.dart';
import 'menu_event.dart';
import 'menu_state.dart';

// 🔗 use the real API client (global dio)
import '../../../core/api_client.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc() : super(const MenuState()) {
    on<MenuStarted>(_onStarted);
    on<MenuCategorySelected>(_onCategorySelected);
    on<MenuRefreshed>(_onRefreshed);
  }

  // Keep a private cache of all items to filter by category
  List<MenuItemModel> _allItems = const [];

  Future<void> _onStarted(MenuStarted event, Emitter<MenuState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      // 1) Fetch categories
      final catsRes = await dio.get('/menu/categories');
      final catsList = (catsRes.data['data'] as List)
          .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // 2) Fetch ALL items once; filter client-side
      final itemsRes = await dio.get('/menu/items');
      _allItems = (itemsRes.data['data'] as List)
          .map((e) => MenuItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      final first = catsList.isNotEmpty ? catsList.first.id : null;
      final filtered = (first == null)
          ? <MenuItemModel>[]
          : _allItems.where((it) => it.categoryId == first).toList();

      emit(
        state.copyWith(
          loading: false,
          categories: catsList,
          selectedCategoryId: first,
          items: filtered,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: 'Не удалось загрузить меню'));
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

    // If cache is empty for some reason, refetch
    if (_allItems.isEmpty) {
      try {
        final itemsRes = await dio.get('/menu/items');
        _allItems = (itemsRes.data['data'] as List)
            .map((e) => MenuItemModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (_) {
        emit(state.copyWith(loading: false, error: 'Не удалось загрузить блюда'));
        return;
      }
    }

    final filtered =
        _allItems.where((it) => it.categoryId == e.categoryId).toList();

    emit(state.copyWith(loading: false, items: filtered));
  }

  Future<void> _onRefreshed(MenuRefreshed e, Emitter<MenuState> emit) async {
    final id = state.selectedCategoryId;
    if (id == null) return;

    emit(state.copyWith(loading: true, error: null));
    try {
      // Refresh the full items list from backend then filter
      final itemsRes = await dio.get('/menu/items');
      _allItems = (itemsRes.data['data'] as List)
          .map((e) => MenuItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      final filtered = _allItems.where((it) => it.categoryId == id).toList();
      emit(state.copyWith(loading: false, items: filtered));
    } catch (e) {
      emit(state.copyWith(loading: false, error: 'Не удалось обновить блюда'));
    }
  }
}
