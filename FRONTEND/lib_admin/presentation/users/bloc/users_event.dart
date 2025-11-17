import 'package:equatable/equatable.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();
  @override
  List<Object?> get props => [];
}

class UsersLoaded extends UsersEvent {
  const UsersLoaded();
}

class UsersPageChanged extends UsersEvent {
  final int page;
  const UsersPageChanged(this.page);

  @override
  List<Object?> get props => [page];
}

class UsersSearchChanged extends UsersEvent {
  final String query;
  const UsersSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class UserRoleChanged extends UsersEvent {
  final int userId;
  final String role;
  const UserRoleChanged(this.userId, this.role);

  @override
  List<Object?> get props => [userId, role];
}

class UserBlocked extends UsersEvent {
  final int userId;
  const UserBlocked(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UserUnblocked extends UsersEvent {
  final int userId;
  const UserUnblocked(this.userId);

  @override
  List<Object?> get props => [userId];
}
