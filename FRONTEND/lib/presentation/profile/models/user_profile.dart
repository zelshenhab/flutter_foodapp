class UserProfile {
  final String? name;
  final String? email;
  final String? avatarPath;
  final String? address;
  final bool? notifications;
  final String? languageCode;

  const UserProfile({
    this.name,
    this.avatarPath,
    this.email,
    this.address,
    this.notifications,
    this.languageCode,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
  return UserProfile(
    name: json['name'] as String?,
    avatarPath: json['avatarUrl'] as String?,
    email: json['email'] as String?,
    address: json['address'] as String?,
    notifications: json['notifications'] as bool?,
    languageCode: json['languageCode'] as String?,
  );
}

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'avatarUrl': avatarPath,
      };
}
