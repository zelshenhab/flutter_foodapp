// lib/presentation/profile/widgets/bonuses_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
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
    final l10n = context.l10n;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final balance = state.loyaltyPoints;

        return Card(
          color: const Color(0xFF1A1A1A),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                      Text(
                        l10n.yourBonuses,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.pointsCount(balance),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.pointEqualsRuble,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: onViewPromos,
                    child: Text(l10n.viewPromos),
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
