import 'package:flutter/foundation.dart';

@immutable
class AdminTicketMessage {
  final String sender; // "user" | "admin"
  final String message;
  final DateTime createdAt;

  const AdminTicketMessage({
    required this.sender,
    required this.message,
    required this.createdAt,
  });

  factory AdminTicketMessage.fromJson(Map<String, dynamic> j) {
    return AdminTicketMessage(
      sender: j['sender'],
      message: j['message'],
      createdAt: DateTime.parse(j['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

@immutable
class AdminTicket {
  final String id;
  final String customer;
  final String subject;
  final String status; // "open" | "closed"
  final DateTime createdAt;
  final List<AdminTicketMessage> messages;

  const AdminTicket({
    required this.id,
    required this.customer,
    required this.subject,
    required this.status,
    required this.createdAt,
    required this.messages,
  });

  factory AdminTicket.fromJson(Map<String, dynamic> j) {
    return AdminTicket(
      id: j['id'].toString(),
      customer: j['customer'],
      subject: j['subject'],
      status: j['status'],
      createdAt: DateTime.parse(j['createdAt']),
      messages: (j['messages'] as List<dynamic>)
          .map((m) => AdminTicketMessage.fromJson(m))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer': customer,
      'subject': subject,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'messages': messages.map((e) => e.toJson()).toList(),
    };
  }

  AdminTicket copyWith({
    String? id,
    String? customer,
    String? subject,
    String? status,
    DateTime? createdAt,
    List<AdminTicketMessage>? messages,
  }) {
    return AdminTicket(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      subject: subject ?? this.subject,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      messages: messages ?? this.messages,
    );
  }
}
