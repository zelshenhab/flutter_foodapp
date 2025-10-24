import 'package:equatable/equatable.dart';
import '../../../data/repos/tickets_repo.dart';

class TicketsState extends Equatable {
  final bool loading;
  final List<AdminTicket> data;
  final String filter;
  final String? error;

  const TicketsState({
    this.loading = false,
    this.data = const [],
    this.filter = 'all',
    this.error,
  });

  TicketsState copyWith({
    bool? loading,
    List<AdminTicket>? data,
    String? filter,
    String? error,
  }) {
    return TicketsState(
      loading: loading ?? this.loading,
      data: data ?? this.data,
      filter: filter ?? this.filter,
      error: error,
    );
  }

  List<AdminTicket> get filtered {
    if (filter == 'all') return data;
    return data.where((t) => t.status == filter).toList();
  }

  int get total => data.length;
  int get openCount => data.where((e) => e.status == 'open').length;
  int get closedCount => data.where((e) => e.status == 'closed').length;

  @override
  List<Object?> get props => [loading, data, filter, error];
}
