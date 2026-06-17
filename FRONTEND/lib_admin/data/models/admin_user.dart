class AdminUser {
  final int id;
  final String? name; // ← Change to nullable
  final String email;
  final String? avatarUrl;
  final String role;
  final bool blocked;
  final DateTime? createdAt;
  final int loyaltyPoints;

  const AdminUser({
    required this.id,
    this.name, // ← Remove required
    required this.email,
    this.avatarUrl,
    required this.role,
    required this.blocked,
    this.createdAt,
    required this.loyaltyPoints, 
  });

  factory AdminUser.fromJson(Map<String, dynamic> j) {
    return AdminUser(
      id: (j['id'] as num).toInt(), // Safer conversion
      name: j['name'] as String?, // Can be null
      email: (j['email'] as String?) ?? '', // Handle null email
      avatarUrl: j['avatarUrl'] as String?,
      role: (j['role'] as String?) ?? 'customer',
      blocked: (j['blocked'] as bool?) ?? false,
      createdAt: j['createdAt'] != null
          ? DateTime.tryParse(j['createdAt'].toString())
          : null,
      loyaltyPoints: (j['loyaltyPoints'] as num?)?.toInt() ?? 0,
    );
  }

  // Add a getter for display name
  String get displayName {
    return name?.isNotEmpty == true ? name! : 'Без имени';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'role': role,
      'blocked': blocked,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  AdminUser copyWith({
    int? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? role,
    bool? blocked,
    DateTime? createdAt,
    int? loyaltyPoints,
  }) {
    return AdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      blocked: blocked ?? this.blocked,
      createdAt: createdAt ?? this.createdAt,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
    );
  }

@override
String toString() {
  return 'AdminUser(id: $id, name: $displayName, email: $email, '
      'role: $role, blocked: $blocked, loyaltyPoints: $loyaltyPoints)';
}
}