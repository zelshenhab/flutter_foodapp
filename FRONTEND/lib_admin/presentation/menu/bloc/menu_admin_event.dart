// lib_admin/presentation/menu/bloc/menu_admin_event.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_foodapp/presentation/menu/models/menu_item.dart';

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
  final MenuItemModel dish;
  const MenuItemAdded(this.dish);
  @override
  List<Object?> get props => [dish];
}

class MenuItemUpdated extends MenuAdminEvent {
  final MenuItemModel dish;
  const MenuItemUpdated(this.dish);
  @override
  List<Object?> get props => [dish];
}

class MenuItemDeleted extends MenuAdminEvent {
  final MenuItemModel dish; // ✅
  const MenuItemDeleted(this.dish);
  @override
  List<Object?> get props => [dish];
}
