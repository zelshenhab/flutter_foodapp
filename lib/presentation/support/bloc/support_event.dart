import 'package:equatable/equatable.dart';

abstract class SupportEvent extends Equatable {
  const SupportEvent();
  @override
  List<Object?> get props => [];
}

class SupportStarted extends SupportEvent {}

class SupportTopicChanged extends SupportEvent {
  final String topic;
  const SupportTopicChanged(this.topic);
  @override
  List<Object?> get props => [topic];
}

class SupportOrderChanged extends SupportEvent {
  final String orderId;
  const SupportOrderChanged(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class SupportMessageChanged extends SupportEvent {
  final String message;
  const SupportMessageChanged(this.message);
  @override
  List<Object?> get props => [message];
}

class SupportSubmitted extends SupportEvent {}
