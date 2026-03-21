import 'package:equatable/equatable.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();
  @override
  List<Object?> get props => [];
}

class MenuStarted extends MenuEvent {}

class MenuCategorySelected extends MenuEvent {
  final String categoryId;
  const MenuCategorySelected(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class MenuRefreshed extends MenuEvent {}

class MenuSearchChanged extends MenuEvent {
  final String query;

  const MenuSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}