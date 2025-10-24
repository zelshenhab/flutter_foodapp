import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../settings/bloc/settings_bloc.dart';
import '../../settings/bloc/settings_event.dart';
import '../../settings/bloc/settings_state.dart';
import '../../../data/repos/settings_repo.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>(
      create: (_) => SettingsBloc(SettingsRepo())..add(const SettingsLoaded()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listenWhen: (p, n) => p.error != n.error || p.saving != n.saving,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        } else if (!state.saving) {
          // بعد الحفظ الناجح (بدون خطأ)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Настройки сохранены')),
          );
        }
      },
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final s = state.settings;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Настройки',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),

            // Системные переключатели
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Уведомлять администраторов'),
                    value: s.notifyAdmins,
                    onChanged: (v) => context
                        .read<SettingsBloc>()
                        .add(SettingsNotifyAdminsToggled(v)),
                  ),
                  SwitchListTile(
                    title: const Text('Тестовый режим'),
                    subtitle: const Text('Отключает реальные платежи и включает имитацию'),
                    value: s.testMode,
                    onChanged: (v) =>
                        context.read<SettingsBloc>().add(SettingsTestModeToggled(v)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Контакты и график работы
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextFormField(
                      key: ValueKey('phone_${s.supportPhone}'),
                      initialValue: s.supportPhone,
                      decoration: const InputDecoration(
                        labelText: 'Телефон поддержки',
                        hintText: '+7 (900) 000-00-00',
                      ),
                      onChanged: (v) => context
                          .read<SettingsBloc>()
                          .add(SettingsSupportPhoneChanged(v)),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      key: ValueKey('email_${s.restaurantEmail}'),
                      initialValue: s.restaurantEmail,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail ресторана',
                        hintText: 'info@restaurant.ru',
                      ),
                      onChanged: (v) =>
                          context.read<SettingsBloc>().add(SettingsEmailChanged(v)),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      key: ValueKey('hours_${s.businessHours}'),
                      initialValue: s.businessHours,
                      decoration: const InputDecoration(
                        labelText: 'Часы работы',
                        hintText: 'Ежедневно: 10:00 — 22:00',
                      ),
                      onChanged: (v) => context
                          .read<SettingsBloc>()
                          .add(SettingsBusinessHoursChanged(v)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Режим обслуживания
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Режим обслуживания (maintenance)'),
                      subtitle: const Text('Показывает пользователям сообщение о техработах'),
                      value: s.maintenanceMode,
                      onChanged: (v) => context
                          .read<SettingsBloc>()
                          .add(SettingsMaintenanceToggled(v)),
                    ),
                    if (s.maintenanceMode) ...[
                      const SizedBox(height: 6),
                      TextFormField(
                        key: ValueKey('mm_${s.maintenanceMessage}'),
                        initialValue: s.maintenanceMessage,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Сообщение для клиентов',
                          hintText: 'Технические работы. Пожалуйста, зайдите позже.',
                        ),
                        onChanged: (v) => context
                            .read<SettingsBloc>()
                            .add(SettingsMaintenanceMessageChanged(v)),
                      ),
                    ]
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context
                        .read<SettingsBloc>()
                        .add(const SettingsResetPressed()),
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Сбросить по умолчанию'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.saving
                        ? null
                        : () => context
                            .read<SettingsBloc>()
                            .add(const SettingsSaved()),
                    icon: state.saving
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('Сохранить'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
