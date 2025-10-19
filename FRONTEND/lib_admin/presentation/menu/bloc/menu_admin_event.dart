import 'package:equatable/equatable.dart';
import '../../../data/repos/menu_repo.dart';

abstract class MenuAdminEvent extends Equatable {
  const MenuAdminEvent();
  @override
  List<Object?> get props => [];
}

class MenuAdminLoaded extends MenuAdminEvent {
  const MenuAdminLoaded();
}

class MenuCategoryChanged extends MenuAdminEvent {
  final String categoryId; // 'pizza', 'shawarma', ...
  const MenuCategoryChanged(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class MenuItemAdded extends MenuAdminEvent {
  final AdminDish dish;
  const MenuItemAdded(this.dish);
  @override
  List<Object?> get props => [dish];
}

class MenuItemUpdated extends MenuAdminEvent {
  final AdminDish dish;
  const MenuItemUpdated(this.dish);
  @override
  List<Object?> get props => [dish];
}

class MenuItemDeleted extends MenuAdminEvent {
  final String dishId;
  const MenuItemDeleted(this.dishId);
  @override
  List<Object?> get props => [dishId];
}
