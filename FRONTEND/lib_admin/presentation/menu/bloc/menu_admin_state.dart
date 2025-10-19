import 'package:equatable/equatable.dart';
import '../../../data/repos/menu_repo.dart';

class MenuAdminState extends Equatable {
  final bool loading;
  final List<AdminCategory> categories;
  final String selectedCategoryId;
  final List<AdminDish> items;
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
    List<AdminCategory>? categories,
    String? selectedCategoryId,
    List<AdminDish>? items,
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
  List<Object?> get props =>
      [loading, categories, selectedCategoryId, items, error];
}
