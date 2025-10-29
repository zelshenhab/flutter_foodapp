import 'dart:convert';

class OrderModel {
  final int id;
  final int userId;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;
  final String? promoCode;
  final String? notes;
  final String addressText;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
    required this.addressText,
    required this.createdAt,
    this.promoCode,
    this.notes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // decode addressSnapshot JSON safely
    String address = '';
    try {
      final addrJson = json['addressSnapshot'];
      if (addrJson != null && addrJson is String && addrJson.isNotEmpty) {
        final decoded = jsonDecode(addrJson);
        address = decoded['text'] ?? '';
      }
    } catch (_) {
      address = '';
    }

    return OrderModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String,
      paymentStatus: json['paymentStatus'] as String,
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
      discount: double.tryParse(json['discount'].toString()) ?? 0,
      deliveryFee: double.tryParse(json['deliveryFee'].toString()) ?? 0,
      total: double.tryParse(json['total'].toString()) ?? 0,
      promoCode: json['promoCode'] as String?,
      notes: json['notes'] as String?,
      addressText: address,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
