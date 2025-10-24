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
}

class TicketClosed extends TicketsEvent {
  final String ticketId;
  const TicketClosed(this.ticketId);
}

class TicketReopened extends TicketsEvent {
  final String ticketId;
  const TicketReopened(this.ticketId);
}

class TicketsFilterChanged extends TicketsEvent {
  final String filter;
  const TicketsFilterChanged(this.filter);
}
