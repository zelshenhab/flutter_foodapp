import 'package:equatable/equatable.dart';

abstract class MenuAdminEvent extends Equatable {
  const MenuAdminEvent();
  @override
  List<Object?> get props => [];
}

class MenuAdminLoaded extends MenuAdminEvent {
  const MenuAdminLoaded();
}

class MenuCategoryChanged extends MenuAdminEvent {
  final String categoryId;
  const MenuCategoryChanged(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class MenuItemAdded extends MenuAdminEvent {
  final Map<String, dynamic> dish;
  const MenuItemAdded(this.dish);

  @override
  List<Object?> get props => [dish];
}

class MenuItemUpdated extends MenuAdminEvent {
  final Map<String, dynamic> dish;
  const MenuItemUpdated(this.dish);

  @override
  List<Object?> get props => [dish];
}

class MenuItemDeleted extends MenuAdminEvent {
  final Map<String, dynamic> dish;
  const MenuItemDeleted(this.dish);

  @override
  List<Object?> get props => [dish];
}
