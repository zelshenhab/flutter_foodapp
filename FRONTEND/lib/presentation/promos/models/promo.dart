// lib/presentation/promos/models/promo.dart
import 'package:equatable/equatable.dart';

enum PromoType { percent, fixed }

class Promo extends Equatable {
  final String id;
  final String title;
  final String description;
  final PromoType type;
  final double amount;
  final String code;
  final DateTime? validTo;
  final double minSubtotal; // Add minimum subtotal requirement

  const Promo({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.amount,
    required this.code,
    this.validTo,
    this.minSubtotal = 0,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    type,
    amount,
    code,
    validTo,
    minSubtotal,
  ];
}