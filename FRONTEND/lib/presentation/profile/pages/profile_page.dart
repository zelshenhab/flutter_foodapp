import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_foodapp/presentation/profile/widgets/bonuses_card.dart';

import '../../promos/pages/promotions_page.dart';
import '../../orders/pages/orders_page.dart';
import '../../support/pages/support_page.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_section_card.dart';
import '../widgets/address_readonly_tile.dart';
import '../widgets/settings_tile_switch.dart';
import '../widgets/settings_tile_language.dart';
import '../models/user_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (p, c) => p.error != c.error,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          // 🔄 Show loading indicator
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ⚠️ Handle error
          if (state.error != null && state.name.isEmpty) {
            return Center(
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          // ✅ Build the actual profile content
          final name = state.name.isNotEmpty ? state.name : '-';
          final email = state.email ?? '-';

          final headerProfile = UserProfile(
            name: name,
            email: email,
            address: 'ул. Пушкина 15',
            notifications: true,
            languageCode: 'ru',
            avatarPath: state.avatarUrl,
          );

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProfileBloc>().add(const ProfileStarted());
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                /// ===== Header (Avatar + name + email)
                ProfileHeader(
                  profile: headerProfile,
                  onEdit: () => _showEditDataSheet(context, name, email),
                  onChangeAvatar: () => _pickAvatar(context),
                ),

                /// ===== Bonuses + Promotions
                _BonusesCardShim(),

                /// ===== Personal data
                const SizedBox(height: 8),
                ProfileSectionCard(
                  title: "Мои данные",
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text("Имя: $name"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: Text("Элек.почта: $email"),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _showEditDataSheet(context, name, email),
                        icon: const Icon(Icons.edit),
                        label: const Text('Редактировать'),
                      ),
                    ),
                  ],
                ),

                /// ===== Orders
                const SizedBox(height: 8),
                ProfileSectionCard(
                  title: "Мои заказы",
                  children: [
                    ListTile(
                      leading: const Icon(Icons.history,
                          color: Color.fromARGB(255, 199, 160, 34)),
                      title: const Text("Посмотреть заказы"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const OrdersPage()),
                        );
                      },
                    ),
                  ],
                ),

                /// ===== Address
                const SizedBox(height: 8),
                const ProfileSectionCard(
                  title: "Адрес доставки",
                  children: [AddressReadonlyTile(address: 'ул. Пушкина 15')],
                ),

                /// ===== Settings
                const SizedBox(height: 8),
                ProfileSectionCard(
                  title: "Настройки",
                  children: [
                    SettingsTileSwitch(
                      title: "Уведомления",
                      value: true,
                      onChanged: (_) {},
                    ),
                    SettingsTileLanguage(
                      currentCode: 'ru',
                      onChanged: (_) {},
                    ),
                  ],
                ),

                /// ===== Support
                const SizedBox(height: 8),
                ProfileSectionCard(
                  title: "Поддержка",
                  children: [
                    ListTile(
                      leading: const Icon(Icons.support_agent,
                          color: Color.fromARGB(255, 199, 160, 34)),
                      title: const Text("Связаться с поддержкой"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SupportPage()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🧾 Bottom Sheet — Edit Name + email
  void _showEditDataSheet(
    BuildContext context,
    String currentName,
    String currentEmail,
  ) {
    final nameCtrl = TextEditingController(text: currentName != '-' ? currentName : '');
    final emailCtrl = TextEditingController(text: currentEmail != '-' ? currentEmail : '');

    const fieldBg = Color(0xFF1E1E1E);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Редактировать данные",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              _buildLabel("Имя"),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Color(0xFFEDEDED)),
                decoration: _inputDecoration("Введите имя", fieldBg),
              ),
              const SizedBox(height: 12),

              _buildLabel("Элек,почта"),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Color(0xFFEDEDED)),
                decoration: _inputDecoration("jhon@mail.ru", fieldBg),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final email = emailCtrl.text.trim();

                    if (name.isEmpty || email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Заполните имя и телефон')),
                      );
                      return;
                    }

                    final bloc = context.read<ProfileBloc>();
                    bloc
                      ..add(ProfileNameChanged(name))
                      ..add(const ProfileSaved());

                    Navigator.pop(context);
                  },
                  child: const Text('Сохранить'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  InputDecoration _inputDecoration(String hint, Color fieldBg) {
    const borderColor = Color(0xFF2A2A2A);
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFA7A7A7)),
      filled: true,
      fillColor: fieldBg,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color.fromARGB(255, 199, 160, 34)),
      ),
    );
  }

  /// 📸 Avatar picker
  Future<void> _pickAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final bloc = context.read<ProfileBloc>();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Камера'),
                onTap: () => Navigator.of(sheetCtx).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Галерея'),
                onTap: () => Navigator.of(sheetCtx).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final xfile = await picker.pickImage(source: source, imageQuality: 85);
      if (xfile == null) return;
      bloc.add(ProfileAvatarSet(xfile.path));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось выбрать изображение')),
      );
    }
  }
}

/// Keeps your existing BonusesCard look
class _BonusesCardShim extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BonusesCard(
      balance: 150,
      onViewPromos: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PromotionsPage()),
        );
      },
    );
  }
}
