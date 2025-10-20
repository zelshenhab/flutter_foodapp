import 'package:equatable/equatable.dart';
import 'package:flutter_foodapp/presentation/menu/models/category.dart';
import 'package:flutter_foodapp/presentation/menu/models/menu_item.dart';

class MenuAdminState extends Equatable {
  final bool loading;
  final List<Category> categories;
  final String selectedCategoryId;
  final List<MenuItemModel> items;
  final String? error;

  const MenuAdminState({
    this.loading = false,
    this.categories = const [],
    this.selectedCategoryId = '',
    this.items = const [],
    this.error,
  });

  MenuAdminState copyWith({
    bool? loading,
    List<Category>? categories,
    String? selectedCategoryId,
    List<MenuItemModel>? items,
    String? error,
  }) {
    return MenuAdminState(
      loading: loading ?? this.loading,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      items: items ?? this.items,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, categories, selectedCategoryId, items, error];
}
