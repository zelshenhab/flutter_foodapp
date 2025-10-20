import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repos/users_repo.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UsersRepo repo;

  // Positional (الأصلي)
  UsersBloc(this.repo) : super(const UsersState()) {
    on<UsersLoaded>(_onLoaded);
    on<UsersSearchChanged>(_onSearch);
    on<UserAdded>(_onAdd);
    on<UserRoleChanged>(_onRole);
    on<UserBlocked>(_onBlock);
  }

  // ✅ Named
  UsersBloc.withRepo({required UsersRepo repo}) : this(repo);

  Future<void> _onLoaded(UsersLoaded e, Emitter<UsersState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await repo.fetchUsers();
      emit(state.copyWith(loading: false, data: list, error: null));
    } catch (_) {
      emit(state.copyWith(
          loading: false, error: 'Не удалось загрузить пользователей'));
    }
  }

  void _onSearch(UsersSearchChanged e, Emitter<UsersState> emit) {
    emit(state.copyWith(search: e.query, error: null));
  }

  Future<void> _onAdd(UserAdded e, Emitter<UsersState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    final ok = await repo.addUser(e.name, e.phone, role: e.role);
    if (!ok) {
      emit(state.copyWith(loading: false, error: 'Ошибка при добавлении'));
      return;
    }
    add(const UsersLoaded());
  }

  Future<void> _onRole(UserRoleChanged e, Emitter<UsersState> emit) async {
    final ok = await repo.updateUserRole(e.userId, e.role);
    if (!ok) {
      emit(state.copyWith(error: 'Ошибка при смене роли'));
      return;
    }
    add(const UsersLoaded());
  }

  Future<void> _onBlock(UserBlocked e, Emitter<UsersState> emit) async {
    final ok = await repo.blockUser(e.userId);
    if (!ok) {
      emit(state.copyWith(error: 'Ошибка при блокировке'));
      return;
    }
    add(const UsersLoaded());
  }
}
