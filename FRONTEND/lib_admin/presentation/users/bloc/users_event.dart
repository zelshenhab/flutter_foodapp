import 'package:equatable/equatable.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();
  @override
  List<Object?> get props => [];
}

class UsersLoaded extends UsersEvent {
  const UsersLoaded();
}

class UsersSearchChanged extends UsersEvent {
  final String query;
  const UsersSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class UserAdded extends UsersEvent {
  final String name;
  final String phone;
  final String role;
  const UserAdded(this.name, this.phone, {this.role = 'customer'});
  @override
  List<Object?> get props => [name, phone, role];
}

class UserRoleChanged extends UsersEvent {
  final String userId;
  final String role;
  const UserRoleChanged(this.userId, this.role);
  @override
  List<Object?> get props => [userId, role];
}

class UserBlocked extends UsersEvent {
  final String userId;
  const UserBlocked(this.userId);
  @override
  List<Object?> get props => [userId];
}
