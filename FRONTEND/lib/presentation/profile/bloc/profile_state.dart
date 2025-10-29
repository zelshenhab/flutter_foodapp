import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final bool loading;
  final String? error;

  final int? id;
  final String? phone;
  final String name;
  final String? avatarUrl;
  final DateTime? createdAt;

  const ProfileState({
    this.loading = false,
    this.error,
    this.id,
    this.phone,
    this.name = '',
    this.avatarUrl,
    this.createdAt,
  });

  ProfileState copyWith({
    bool? loading,
    String? error,
    int? id,
    String? phone,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return ProfileState(
      loading: loading ?? this.loading,
      error: error,
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [loading, error, id, phone, name, avatarUrl, createdAt];
}
