import 'package:equatable/equatable.dart';
import '../../../data/models/admin_promo.dart';

class PromosState extends Equatable {
  final bool loading;
  final List<AdminPromo> data;
  final String? error;

  const PromosState({
    this.loading = false,
    this.data = const [],
    this.error,
  });

  PromosState copyWith({
    bool? loading,
    List<AdminPromo>? data,
    String? error,
  }) {
    return PromosState(
      loading: loading ?? this.loading,
      data: data ?? this.data,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, data, error];
}
