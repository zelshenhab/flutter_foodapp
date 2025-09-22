class UserProfile {
  final String name;
  final String phone;
  final String? email;
  final String address;
  final bool notifications;
  final String languageCode;
  final String? avatarPath; // ملف محلي أو Network لاحقًا

  const UserProfile({
    required this.name,
    required this.phone,
    this.email,
    this.address = 'ул. Пушкина 15',
    this.notifications = true,
    this.languageCode = 'ru',
    this.avatarPath,
  });

  UserProfile copyWith({
    String? name,
    String? phone,
    String? email,
    String? address,
    bool? notifications,
    String? languageCode,
    String? avatarPath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      notifications: notifications ?? this.notifications,
      languageCode: languageCode ?? this.languageCode,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}
