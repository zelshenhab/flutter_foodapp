import 'package:equatable/equatable.dart';
import '../models/category.dart';
import '../models/menu_item.dart';

class MenuState extends Equatable {
  final bool loading;
  final String? error;
  final List<Category> categories;
  final String? selectedCategoryId;
  final List<MenuItemModel> items;

  const MenuState({
    this.loading = false,
    this.error,
    this.categories = const [],
    this.selectedCategoryId,
    this.items = const [],
  });

  MenuState copyWith({
    bool? loading,
    String? error,
    List<Category>? categories,
    String? selectedCategoryId,
    List<MenuItemModel>? items,
  }) {
    return MenuState(
      loading: loading ?? this.loading,
      error: error,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [loading, error, categories, selectedCategoryId, items];
}
