import 'package:equatable/equatable.dart';

abstract class PromosEvent extends Equatable {
  const PromosEvent();
  @override
  List<Object?> get props => [];
}

class PromosStarted extends PromosEvent {}

class PromosRefreshed extends PromosEvent {}
