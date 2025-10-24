import 'dart:async';
import '../admin_api_client.dart';

class AdminTicketMessage {
  final String sender; // customer/admin
  final String message;
  final DateTime time;

  const AdminTicketMessage({
    required this.sender,
    required this.message,
    required this.time,
  });
}

class AdminTicket {
  final String id;
  final String subject;
  final String customer;
  final String createdAt;
  final String status; // open | closed
  final List<AdminTicketMessage> messages;

  const AdminTicket({
    required this.id,
    required this.subject,
    required this.customer,
    required this.createdAt,
    required this.status,
    this.messages = const [],
  });

  AdminTicket copyWith({
    String? id,
    String? subject,
    String? customer,
    String? createdAt,
    String? status,
    List<AdminTicketMessage>? messages,
  }) {
    return AdminTicket(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      customer: customer ?? this.customer,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      messages: messages ?? this.messages,
    );
  }
}

///
/// Mock TicketsRepo — без реального backend пока.
///
class TicketsRepo {
  final AdminApiClient? api;
  TicketsRepo([this.api]);

  static final List<AdminTicket> _tickets = [
    AdminTicket(
      id: '1001',
      subject: 'Проблема с оплатой',
      customer: 'Ахмед Мухаммед',
      createdAt: '2025-10-20',
      status: 'open',
      messages: [
        AdminTicketMessage(
          sender: 'customer',
          message: 'Не удалось завершить оплату картой.',
          time: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ],
    ),
    AdminTicket(
      id: '1002',
      subject: 'Заказ не доставлен',
      customer: 'Махмуд Али',
      createdAt: '2025-10-21',
      status: 'closed',
      messages: [
        AdminTicketMessage(
          sender: 'customer',
          message: 'Заказ не был доставлен вовремя.',
          time: DateTime.now().subtract(const Duration(days: 1)),
        ),
        AdminTicketMessage(
          sender: 'admin',
          message: 'Проблема решена, заказ был доставлен позже ✅',
          time: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ],
    ),
    AdminTicket(
      id: '1003',
      subject: 'Ошибка в приложении',
      customer: 'Иван Петров',
      createdAt: '2025-10-22',
      status: 'open',
      messages: [
        AdminTicketMessage(
          sender: 'customer',
          message: 'Приложение вылетает при оформлении заказа.',
          time: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ],
    ),
  ];

  Future<List<AdminTicket>> fetchTickets() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_tickets);
  }

  Future<bool> reply(String id, String msg) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final i = _tickets.indexWhere((t) => t.id == id);
    if (i == -1) return false;
    final updated = _tickets[i].copyWith(
      messages: [
        ..._tickets[i].messages,
        AdminTicketMessage(sender: 'admin', message: msg, time: DateTime.now()),
      ],
    );
    _tickets[i] = updated;
    return true;
  }

  Future<bool> close(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final i = _tickets.indexWhere((t) => t.id == id);
    if (i == -1) return false;
    _tickets[i] = _tickets[i].copyWith(status: 'closed');
    return true;
  }

  Future<bool> reopen(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final i = _tickets.indexWhere((t) => t.id == id);
    if (i == -1) return false;
    _tickets[i] = _tickets[i].copyWith(status: 'open');
    return true;
  }
}
