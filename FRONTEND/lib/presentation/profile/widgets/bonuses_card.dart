// lib/presentation/profile/widgets/bonuses_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/presentation/profile/bloc/profile_state.dart';
import '../bloc/profile_bloc.dart';

class BonusesCard extends StatelessWidget {
  final VoidCallback onViewPromos;

  const BonusesCard({
    super.key,
    required this.onViewPromos,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final balance = state.loyaltyPoints;
        
        return Card(
          color: const Color(0xFF1A1A1A),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(
                  Icons.stars_rounded,
                  size: 28,
                  color: Color.fromARGB(255, 199, 160, 34),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Бонусный счет',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$balance баллов',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '1 балл = 1 ₽',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: onViewPromos,
                    child: const Text('Посмотреть акции'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}