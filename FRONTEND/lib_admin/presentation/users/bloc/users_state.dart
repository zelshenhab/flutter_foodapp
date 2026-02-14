import 'package:equatable/equatable.dart';
import '../../../data/models/admin_user.dart';

class UsersState extends Equatable {
  final bool loading;
  final List<AdminUser> data;
  final String search;
  final String? error;
  final int page;
  final int totalPages;

  const UsersState({
    this.loading = false,
    this.data = const [],
    this.search = '',
    this.error,
    this.page = 1,
    this.totalPages = 1,
  });

  UsersState copyWith({
    bool? loading,
    List<AdminUser>? data,
    String? search,
    String? error,
    int? page,
    int? totalPages,
  }) {
    return UsersState(
      loading: loading ?? this.loading,
      data: data ?? this.data,
      search: search ?? this.search,
      error: error,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  List<AdminUser> get filtered {
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return data;

    return data.where((u) {
      final name = (u.name ?? '').toLowerCase();
      final email = u.email.toLowerCase();
      return name.contains(q) || email.contains(q);
    }).toList();
  }

  @override
  List<Object?> get props => [loading, data, search, error, page, totalPages];
}
