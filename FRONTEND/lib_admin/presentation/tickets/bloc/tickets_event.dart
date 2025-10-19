import 'package:equatable/equatable.dart';

abstract class TicketsEvent extends Equatable {
  const TicketsEvent();
  @override
  List<Object?> get props => [];
}

class TicketsLoaded extends TicketsEvent {
  const TicketsLoaded();
}

class TicketReplySent extends TicketsEvent {
  final String ticketId;
  final String message;
  const TicketReplySent(this.ticketId, this.message);
  @override
  List<Object?> get props => [ticketId, message];
}

class TicketClosed extends TicketsEvent {
  final String ticketId;
  const TicketClosed(this.ticketId);
  @override
  List<Object?> get props => [ticketId];
}

class TicketsFilterChanged extends TicketsEvent {
  final String filter; // all/open/closed
  const TicketsFilterChanged(this.filter);
  @override
  List<Object?> get props => [filter];
}
