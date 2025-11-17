import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override
  List<Object?> get props => [];
}

class AnalyticsLoad extends AnalyticsEvent {
  final DateTime? from;
  final DateTime? to;
  const AnalyticsLoad({this.from, this.to});
}
