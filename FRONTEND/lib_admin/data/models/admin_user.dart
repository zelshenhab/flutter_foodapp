class AdminUser {
  final int id;
  final String? name; // ← Change to nullable
  final String phone;
  final String? avatarUrl;
  final String role;
  final bool blocked;
  final DateTime? createdAt;

  const AdminUser({
    required this.id,
    this.name, // ← Remove required
    required this.phone,
    this.avatarUrl,
    required this.role,
    required this.blocked,
    this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> j) {
    return AdminUser(
      id: (j['id'] as num).toInt(), // Safer conversion
      name: j['name'] as String?, // Can be null
      phone: (j['phone'] as String?) ?? '', // Handle null phone
      avatarUrl: j['avatarUrl'] as String?,
      role: (j['role'] as String?) ?? 'customer',
      blocked: (j['blocked'] as bool?) ?? false,
      createdAt: j['createdAt'] != null
          ? DateTime.tryParse(j['createdAt'].toString())
          : null,
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
      'phone': phone,
      'avatarUrl': avatarUrl,
      'role': role,
      'blocked': blocked,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  AdminUser copyWith({
    int? id,
    String? name,
    String? phone,
    String? avatarUrl,
    String? role,
    bool? blocked,
    DateTime? createdAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      blocked: blocked ?? this.blocked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'AdminUser(id: $id, name: $name, phone: $phone, role: $role)';
  }
}