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

  const Promo({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.amount,
    required this.code,
    this.validTo,
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
  ];
}
