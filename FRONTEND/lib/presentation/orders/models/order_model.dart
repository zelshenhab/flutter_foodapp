import 'dart:convert';
import 'order_item.dart';

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
  final String? branchId;
  final DateTime createdAt;
  final List<OrderItem> items;

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
    required this.items,
    this.promoCode,
    this.notes,
    this.branchId,
  });

  bool get isActive =>
      status == 'pending' || status == 'preparing' || status == 'ready';

  OrderModel copyWith({
    String? status,
    String? addressText,
    String? branchId,
    List<OrderItem>? items,
  }) {
    return OrderModel(
      id: id,
      userId: userId,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      total: total,
      addressText: addressText ?? this.addressText,
      branchId: branchId ?? this.branchId,
      promoCode: promoCode,
      notes: notes,
      createdAt: createdAt,
      items: items ?? this.items,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    String address = '';
    String? branchId;
    try {
      final addrJson = json['addressSnapshot'];
      Map<String, dynamic>? map;
      if (addrJson is String && addrJson.isNotEmpty) {
        final decoded = jsonDecode(addrJson);
        if (decoded is Map<String, dynamic>) map = decoded;
      } else if (addrJson is Map<String, dynamic>) {
        map = addrJson;
      }
      if (map != null) {
        address = map['text']?.toString() ?? '';
        final rawBranch = map['branchId']?.toString();
        if (rawBranch != null && rawBranch.isNotEmpty) {
          branchId = rawBranch;
        }
      }
    } catch (_) {
      address = '';
      branchId = null;
    }

    final rawItems = json['items'] ?? json['OrderItem'];
    List<OrderItem> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems
          .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return OrderModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['userId'] is int
          ? json['userId']
          : int.tryParse(json['userId'].toString()) ?? 0,
      status: json['status']?.toString() ?? 'unknown',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
      discount: double.tryParse(json['discount'].toString()) ?? 0,
      deliveryFee: double.tryParse(json['deliveryFee'].toString()) ?? 0,
      total: double.tryParse(json['total'].toString()) ?? 0,
      promoCode: json['promoCode']?.toString(),
      notes: json['notes']?.toString(),
      addressText: address,
      branchId: branchId,
      createdAt:
          DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now(),
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'status': status,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'subtotal': subtotal,
        'discount': discount,
        'deliveryFee': deliveryFee,
        'total': total,
        'promoCode': promoCode,
        'notes': notes,
        'addressText': addressText,
        'branchId': branchId,
        'createdAt': createdAt.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
      };
}
