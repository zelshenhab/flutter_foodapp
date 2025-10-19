import 'package:flutter/material.dart';

class RestaurantHeader extends StatelessWidget {
  final bool showName;
  final bool showPickupBadge;
  final String? pickupAddress;

  const RestaurantHeader({
    super.key,
    this.showName = false,
    this.showPickupBadge = false,
    this.pickupAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          if (showPickupBadge) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: const Text('Самовывоз', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showName)
                  const Text('Адам и Ева', style: TextStyle(fontWeight: FontWeight.w800)),
                if (pickupAddress != null) ...[
                  const SizedBox(height: 4),
                  Text(pickupAddress!, style: const TextStyle(color: Color(0xFFA7A7A7))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
