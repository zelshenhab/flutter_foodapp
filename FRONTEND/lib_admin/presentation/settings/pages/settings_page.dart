import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, s) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Настройки',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Уведомлять администраторов'),
                    value: s.notifyAdmins,
                    onChanged: (v) =>
                        context.read<SettingsCubit>().toggleNotifyAdmins(v),
                  ),
                  SwitchListTile(
                    title: const Text('Тестовый режим'),
                    value: s.testMode,
                    onChanged: (v) =>
                        context.read<SettingsCubit>().toggleTestMode(v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Настройки сохранены (mock)')),
                );
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}
