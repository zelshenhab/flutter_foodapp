import 'package:flutter/material.dart';

class SettingsTileLanguage extends StatelessWidget {
  final String currentCode;
  final ValueChanged<String> onChanged;
  const SettingsTileLanguage({
    super.key,
    required this.currentCode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.language, color: Color.fromARGB(255, 199, 160, 34)),
      title: const Text("Язык"),
      trailing: DropdownButton<String>(
        value: currentCode,
        items: const [
          DropdownMenuItem(value: 'ru', child: Text("Русский")),
        ],
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}
