import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';

class MenuHeader extends StatelessWidget {
  const MenuHeader({super.key});

  void _openMap() {
    MapsLauncher.launchQuery("ул. Николая Ершова, 62, Казань");
  }

  @override
  Widget build(BuildContext context) {
    const text = Color(0xFFEDEDED);
    const muted = Color(0xFFA7A7A7);
    const chipBg = Color(0xFF1E1E1E);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Адам и Ева',
                  style: TextStyle(
                      color: text,
                      fontSize: 22,
                      fontWeight: FontWeight.w800),
                ),
              ),
             /* Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                    color: chipBg, shape: BoxShape.circle),
                child:
                    const Icon(Icons.person_outline, color: text, size: 20),
              ),*/
            ],
          ),
          const SizedBox(height: 10),

          /// LOCATION BUTTON
          GestureDetector(
            onTap: _openMap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: muted),
                  SizedBox(width: 6),
                  Text(
                    'Kazan, Russia',
                    style: TextStyle(color: muted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}