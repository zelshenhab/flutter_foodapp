import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_foodapp/presentation/auth/pages/login_info_page.dart';
import 'package:flutter_foodapp/presentation/profile/widgets/bonuses_card.dart';
import 'package:flutter_foodapp/presentation/promos/pages/promotions_page.dart';
import 'package:flutter_foodapp/presentation/orders/pages/orders_page.dart';
import 'package:flutter_foodapp/presentation/support/pages/support_page.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

import '../widgets/profile_header.dart';
import '../widgets/profile_section_card.dart';
import '../widgets/address_readonly_tile.dart';
import '../widgets/settings_tile_switch.dart';
import '../widgets/settings_tile_language.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ مفيش BlocProvider هنا — AppShell هو اللي موفّر ProfileBloc
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (prev, next) =>
          prev.profile != next.profile || prev.loading != next.loading,
      listener: (context, state) {
        // لما يحصل تسجيل خروج (profile == null) نرجّع لصفحة تسجيل الدخول
        if (!state.loading && state.profile == null) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginInfoPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Профиль'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // لو حابب تعمل تأكيد قبل الخروج، قدر تضيف Dialog هنا
                context.read<ProfileBloc>().add(ProfileLogoutRequested());
              },
            ),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.profile == null) {
              // الحالة المؤقتة بين الضغط على الخروج والتنقل (هيتلقطها الـ Listener فوق)
              return const SizedBox.shrink();
            }
            final profile = state.profile!;

            return ListView(
              children: [
                // ===== Header (Avatar + name + phone)
                ProfileHeader(
                  profile: profile,
                  onEdit: () =>
                      _showEditDataSheet(context, profile.name, profile.phone),
                  onChangeAvatar: () => _pickAvatar(context),
                ),

                // ===== Bonuses + Promotions
                BonusesCard(
                  balance: 150, // مبدئيًا — بعدين من الباك-энд
                  onViewPromos: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PromotionsPage()),
                    );
                  },
                ),

                // ===== Personal data (editable)
                const SizedBox(height: 8),
                ProfileSectionCard(
                  title: "Мои данные",
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text("Имя: ${profile.name}"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text("Телефон: ${profile.phone}"),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _showEditDataSheet(
                          context,
                          profile.name,
                          profile.phone,
                        ),
                        icon: const Icon(Icons.edit),
                        label: const Text('Редактировать'),
                      ),
                    ),
                  ],
                ),

                // ===== Orders entry
                const SizedBox(height: 8),
                ProfileSectionCard(
                  title: "Мои заказы",
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.history,
                        color: Colors.orangeAccent,
                      ),
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

                // ===== Address (read-only)
                const SizedBox(height: 8),
                ProfileSectionCard(
                  title: "Адрес доставки",
                  children: [AddressReadonlyTile(address: profile.address)],
                ),

                // ===== Settings
                const SizedBox(height: 8),
                ProfileSectionCard(
                  title: "Настройки",
                  children: [
                    SettingsTileSwitch(
                      title: "Уведомления",
                      value: profile.notifications,
                      onChanged: (v) => context.read<ProfileBloc>().add(
                        ProfileNotificationsToggled(v),
                      ),
                    ),
                    SettingsTileLanguage(
                      currentCode: profile.languageCode,
                      onChanged: (c) => context.read<ProfileBloc>().add(
                        ProfileLanguageChanged(c),
                      ),
                    ),
                  ],
                ),

                // ===== Support
                const SizedBox(height: 8),
                ProfileSectionCard(
                  title: "Поддержка",
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.support_agent,
                        color: Colors.orangeAccent,
                      ),
                      title: const Text("Связаться с поддержкой"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SupportPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }

  /// BottomSheet: تعديل الاسم + الهاتف معاً
  void _showEditDataSheet(
    BuildContext context,
    String currentName,
    String currentPhone,
  ) {
    final nameCtrl = TextEditingController(text: currentName);
    final phoneCtrl = TextEditingController(text: currentPhone);

    const borderColor = Color(0xFF2A2A2A);
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

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Имя",
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Color(0xFFEDEDED)),
                decoration: InputDecoration(
                  hintText: 'Введите имя',
                  hintStyle: const TextStyle(color: Color(0xFFA7A7A7)),
                  filled: true,
                  fillColor: fieldBg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Телефон",
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Color(0xFFEDEDED)),
                decoration: InputDecoration(
                  hintText: '+7 999 123-45-67',
                  hintStyle: const TextStyle(color: Color(0xFFA7A7A7)),
                  filled: true,
                  fillColor: fieldBg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final phone = phoneCtrl.text.trim();

                    if (name.isEmpty || phone.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Заполните имя и телефон'),
                        ),
                      );
                      return;
                    }
                    if (!RegExp(r'^\+?\d[\d \-\(\)]{9,}$').hasMatch(phone)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Введите корректный номер телефона'),
                        ),
                      );
                      return;
                    }

                    context.read<ProfileBloc>().add(
                      ProfileInfoUpdated(name: name, phone: phone),
                    );
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

  /// اختيار صورة جديدة (كاميرا/معرض) ثم إرسال ProfileAvatarUpdated
  Future<void> _pickAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final bloc = context.read<ProfileBloc>(); // ✅ خزّناه قبل await

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
      bloc.add(ProfileAvatarUpdated(xfile.path)); // ✅ استخدمنا bloc المخزّن
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось выбрать изображение')),
      );
    }
  }
}
