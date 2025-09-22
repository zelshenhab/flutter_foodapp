import 'package:flutter/material.dart';

class RestaurantHeader extends StatelessWidget {
  final bool showName; // لو عايز تخفي الاسم خلّيه false
  const RestaurantHeader({super.key, this.showName = true});

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFFA7A7A7);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showName)
            const Text('Адам и Ева',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Row(
            children: const [
              Icon(Icons.timer_outlined, size: 16, color: muted),
              SizedBox(width: 6),
              Text('Время приготовления: 25–35 мин',
                  style: TextStyle(color: muted, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}
