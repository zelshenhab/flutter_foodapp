import 'package:equatable/equatable.dart';

class AnalyticsState extends Equatable {
  final bool loading;
  final String? error;

  final List<dynamic> dailyRevenue;
  final Map<String, dynamic> ordersByStatus;
  final List<dynamic> bestSelling;
  final Map<String, dynamic> summary;

  const AnalyticsState({
    this.loading = false,
    this.error,
    this.dailyRevenue = const [],
    this.ordersByStatus = const {},
    this.bestSelling = const [],
    this.summary = const {},
  });

  AnalyticsState copyWith({
    bool? loading,
    String? error,
    List<dynamic>? dailyRevenue,
    Map<String, dynamic>? ordersByStatus,
    List<dynamic>? bestSelling,
    Map<String, dynamic>? summary,
  }) {
    return AnalyticsState(
      loading: loading ?? this.loading,
      error: error,
      dailyRevenue: dailyRevenue ?? this.dailyRevenue,
      ordersByStatus: ordersByStatus ?? this.ordersByStatus,
      bestSelling: bestSelling ?? this.bestSelling,
      summary: summary ?? this.summary,
    );
  }

  @override
  List<Object?> get props =>
      [loading, error, dailyRevenue, ordersByStatus, bestSelling, summary];
}
