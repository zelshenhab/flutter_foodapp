import 'package:flutter/material.dart';
import 'package:flutter_foodapp/presentation/profile/models/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEdit;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // SIMPLE: Just combine name + surname for display
    final String displayName = [
      profile.name?.trim(),
    ].where((part) => part != null && part.isNotEmpty).join(' ');

    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1A1A1A),
      child: Row(
        children: [
          // Just a simple CircleAvatar with person icon - no tap functionality
          const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.grey,
            child: Icon(
              Icons.person,
              size: 32,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName.isEmpty ? '-' : displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, color: Color.fromARGB(255, 199, 160, 34)),
          ),
        ],
      ),
    );
  }
}