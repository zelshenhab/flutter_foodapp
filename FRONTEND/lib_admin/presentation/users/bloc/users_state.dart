import 'package:equatable/equatable.dart';
import '../../../data/repos/users_repo.dart';

class UsersState extends Equatable {
  final bool loading;
  final List<AdminUser> data;
  final String search;
  final String? error;

  const UsersState({
    this.loading = false,
    this.data = const [],
    this.search = '',
    this.error,
  });

  UsersState copyWith({
    bool? loading,
    List<AdminUser>? data,
    String? search,
    String? error, // ضع null لمسح الرسالة
  }) {
    return UsersState(
      loading: loading ?? this.loading,
      data: data ?? this.data,
      search: search ?? this.search,
      error: error,
    );
  }

  List<AdminUser> get filtered {
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return data;
    return data.where((u) =>
      u.name.toLowerCase().contains(q) || u.phone.toLowerCase().contains(q)
    ).toList();
  }

  @override
  List<Object?> get props => [loading, data, search, error];
}
