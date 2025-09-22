import 'package:equatable/equatable.dart';
import '../models/promo.dart';

class PromosState extends Equatable {
  final bool loading;
  final String? error;
  final List<Promo> promos;

  const PromosState({
    this.loading = false,
    this.error,
    this.promos = const [],
  });

  PromosState copyWith({
    bool? loading,
    String? error,
    List<Promo>? promos,
  }) {
    return PromosState(
      loading: loading ?? this.loading,
      error: error,
      promos: promos ?? this.promos,
    );
  }

  @override
  List<Object?> get props => [loading, error, promos];
}
