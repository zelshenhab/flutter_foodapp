import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEdit; // يفتح شيت تعديل الاسم/الهاتف
  final VoidCallback onChangeAvatar; // يفتح اختيار صورة

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onEdit,
    required this.onChangeAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasAvatar = profile.avatarPath != null;
    final ImageProvider? imgProvider = hasAvatar
        ? FileImage(File(profile.avatarPath!))
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1A1A1A),
      child: Row(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: onChangeAvatar,
                child: CircleAvatar(
                  radius: 32,
                  backgroundImage: imgProvider, // لو null → هيتعرض الـ child
                  backgroundColor: Colors.grey[800],
                  child: !hasAvatar
                      ? const Icon(
                          Icons.person,
                          size: 32,
                          color: Colors.white70,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: onChangeAvatar,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.orangeAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(profile.phone, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, color: Colors.orangeAccent),
          ),
        ],
      ),
    );
  }
}
