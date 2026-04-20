// lib/presentation/profile/bloc/profile_state.dart
import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final bool loading;
  final String? error;

  final int? id;
  final String? email;
  final String name;
  final String? avatarUrl;
  final int loyaltyPoints; // 👈 ADD THIS
  final DateTime? createdAt;

  const ProfileState({
    this.loading = false,
    this.error,
    this.id,
    this.email,
    this.name = '',
    this.avatarUrl,
    this.loyaltyPoints = 0, // 👈 ADD THIS
    this.createdAt,
  });

  ProfileState copyWith({
    bool? loading,
    String? error,
    int? id,
    String? email,
    String? name,
    String? avatarUrl,
    int? loyaltyPoints, // 👈 ADD THIS
    DateTime? createdAt,
  }) {
    return ProfileState(
      loading: loading ?? this.loading,
      error: error,
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints, // 👈 ADD THIS
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    loading, 
    error, 
    id, 
    email, 
    name, 
    avatarUrl, 
    loyaltyPoints, // 👈 ADD THIS
    createdAt
  ];
}