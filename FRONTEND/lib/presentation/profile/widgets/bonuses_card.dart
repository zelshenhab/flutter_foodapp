import 'package:flutter/material.dart';

class BonusesCard extends StatelessWidget {
  final int balance; // رصيد النقاط/الروبل
  final VoidCallback onViewPromos;

  const BonusesCard({
    super.key,
    required this.balance,
    required this.onViewPromos,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.stars_rounded, size: 28, color: Colors.orangeAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ваши бонусы',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('$balance ₽',
                      style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900)),
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
  }
}
