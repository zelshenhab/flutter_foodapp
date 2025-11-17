import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/admin_user.dart';
import '../../../data/repos/users_repo.dart';

import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UsersRepo repo;

  UsersBloc(this.repo) : super(const UsersState()) {
    on<UsersLoaded>((e, emit) => _loadPage(1, emit));
    on<UsersPageChanged>((e, emit) => _loadPage(e.page, emit));
    on<UsersSearchChanged>(_onSearch);
    on<UserRoleChanged>(_onRole);
    on<UserBlocked>(_onBlock);
    on<UserUnblocked>(_onUnblock);
    on<UsersErrorDismissed>((e, emit) => emit(state.copyWith(error: null)));
  }

  Future<void> _loadPage(int page, Emitter<UsersState> emit) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final res = await repo.fetchUsers(page: page);
      final List raw = res["data"] ?? [];
      final totalPages = res["totalPages"] ?? 1;

      final users = raw.map((j) => AdminUser.fromJson(j)).toList();

      emit(state.copyWith(
        loading: false,
        data: users,
        page: page,
        totalPages: totalPages,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: "Не удалось загрузить пользователей",
      ));
    }
  }

  void _onSearch(UsersSearchChanged e, Emitter<UsersState> emit) {
    emit(state.copyWith(search: e.query));
  }

  Future<void> _onRole(UserRoleChanged e, Emitter<UsersState> emit) async {
    final oldUsers = List<AdminUser>.from(state.data);
    
    // Optimistic update
    final optimisticUsers = oldUsers.map((user) {
      if (user.id == e.userId) {
        return user.copyWith(role: e.role);
      }
      return user;
    }).toList();
    
    emit(state.copyWith(data: optimisticUsers, error: null));

    final ok = await repo.updateUserRole(e.userId, e.role);
    if (!ok) {
      // Revert on failure
      emit(state.copyWith(
        data: oldUsers,
        error: 'Ошибка при смене роли'
      ));
      return;
    }
    
    // Success - refresh to get latest data
    add(UsersPageChanged(state.page));
  }

  Future<void> _onBlock(UserBlocked e, Emitter<UsersState> emit) async {
    final oldUsers = List<AdminUser>.from(state.data);
    
    // Optimistic update - use 'blocked' field
    final optimisticUsers = oldUsers.map((user) {
      if (user.id == e.userId) {
        return user.copyWith(blocked: true);
      }
      return user;
    }).toList();
    
    emit(state.copyWith(data: optimisticUsers, error: null));

    final ok = await repo.blockUser(e.userId);
    if (!ok) {
      // Revert on failure
      emit(state.copyWith(
        data: oldUsers,
        error: 'Ошибка при блокировке'
      ));
      return;
    }
    
    // Success - refresh to get latest data
    add(UsersPageChanged(state.page));
  }

  Future<void> _onUnblock(UserUnblocked e, Emitter<UsersState> emit) async {
    final oldUsers = List<AdminUser>.from(state.data);
    
    // Optimistic update - use 'blocked' field
    final optimisticUsers = oldUsers.map((user) {
      if (user.id == e.userId) {
        return user.copyWith(blocked: false);
      }
      return user;
    }).toList();
    
    emit(state.copyWith(data: optimisticUsers, error: null));

    final ok = await repo.unblockUser(e.userId);
    if (!ok) {
      // Revert on failure
      emit(state.copyWith(
        data: oldUsers,
        error: 'Ошибка при разблокировке'
      ));
      return;
    }
    
    // Success - refresh to get latest data
    add(UsersPageChanged(state.page));
  }
}