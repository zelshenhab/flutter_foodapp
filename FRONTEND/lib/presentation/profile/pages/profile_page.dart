import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
import 'package:flutter_foodapp/core/l10n/locale_cubit.dart';
import 'package:flutter_foodapp/core/branches/branch_cubit.dart';
import 'package:flutter_foodapp/presentation/auth/bloc/auth_bloc.dart';
import 'package:flutter_foodapp/presentation/auth/bloc/auth_event.dart';
import 'package:flutter_foodapp/presentation/common/widgets/app_toast.dart';
import 'package:flutter_foodapp/presentation/common/widgets/branch_selector.dart';
import 'package:flutter_foodapp/presentation/profile/widgets/bonuses_card.dart';
import 'package:flutter_foodapp/presentation/promos/pages/promotions_page.dart';

import '../../orders/pages/orders_page.dart';
import '../../support/pages/support_page.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_section_card.dart';
import '../widgets/settings_tile_switch.dart';
import '../widgets/settings_tile_language.dart';
import '../models/user_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final langCode = context.watch<LocaleCubit>().state.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (p, c) => p.error != c.error,
        listener: (context, state) {
          if (state.error != null) {
            AppToast.error(context, state.error!);
          }
        },
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.name.isEmpty) {
            return Center(
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final name = state.name.isNotEmpty ? state.name : '-';
          final email = state.email ?? '-';

          final headerProfile = UserProfile(
            name: name,
            email: email,
            address: context.watch<BranchCubit>().state.fullAddress,
            notifications: true,
            languageCode: langCode,
            avatarPath: state.avatarUrl,
          );

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProfileBloc>().add(const ProfileStarted());
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                ProfileHeader(
                  profile: headerProfile,
                  onEdit: () => _showEditDataSheet(context, name, email),
                ),
                _BonusesCardShim(),
                const SizedBox(height: 8),
                ProfileSectionCard(
                  title: l10n.myData,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(l10n.nameLabel(name)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: Text(l10n.emailLabel(email)),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () =>
                            _showEditDataSheet(context, name, email),
                        icon: const Icon(Icons.edit),
                        label: Text(l10n.edit),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ProfileSectionCard(
                  title: l10n.myOrders,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.history,
                          color: Color.fromARGB(255, 199, 160, 34)),
                      title: Text(l10n.viewOrders),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const OrdersPage()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ProfileSectionCard(
                  title: l10n.restaurantAddress,
                  children: const [
                    BranchSelectorTile(),
                  ],
                ),
                const SizedBox(height: 8),
                ProfileSectionCard(
                  title: l10n.settings,
                  children: [
                    SettingsTileSwitch(
                      title: l10n.notifications,
                      value: true,
                      onChanged: (_) {},
                    ),
                    const SettingsTileLanguage(),
                  ],
                ),
                const SizedBox(height: 8),
                ProfileSectionCard(
                  title: l10n.support,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.support_agent,
                          color: Color.fromARGB(255, 199, 160, 34)),
                      title: Text(l10n.contactSupport),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SupportPage()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 8),
                ProfileSectionCard(
                  title: l10n.account,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.orange),
                      title: Text(l10n.logout),
                      onTap: () {
                        context.read<AuthBloc>().add(AuthLogoutRequested());

                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login',
                          (route) => false,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: Text(l10n.deleteAccount),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(l10n.deleteAccount),
                            content: Text(l10n.deleteAccountConfirm),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(context.l10n.cancel),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);

                                  context
                                      .read<AuthBloc>()
                                      .add(AuthDeleteAccountRequested());

                                  Navigator.of(context)
                                      .pushNamedAndRemoveUntil(
                                    '/login',
                                    (route) => false,
                                  );
                                },
                                child: Text(
                                  l10n.delete,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditDataSheet(
    BuildContext context,
    String currentName,
    String currentEmail,
  ) {
    final l10n = context.l10n;
    final nameCtrl =
        TextEditingController(text: currentName != '-' ? currentName : '');
    final emailCtrl =
        TextEditingController(text: currentEmail != '-' ? currentEmail : '');

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
              Text(
                l10n.editData,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _buildLabel(l10n.name),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Color(0xFFEDEDED)),
                decoration: _inputDecoration(l10n.enterName, fieldBg),
              ),
              const SizedBox(height: 12),
              _buildLabel(l10n.email),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Color(0xFFEDEDED)),
                decoration: _inputDecoration('john@mail.ru', fieldBg),
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
                      AppToast.error(context, l10n.fillNameEmail);
                      return;
                    }

                    final bloc = context.read<ProfileBloc>();
                    bloc
                      ..add(ProfileNameChanged(name))
                      ..add(const ProfileSaved());

                    Navigator.pop(context);
                  },
                  child: Text(l10n.save),
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
        borderSide:
            const BorderSide(color: Color.fromARGB(255, 199, 160, 34)),
      ),
    );
  }
}

class _BonusesCardShim extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BonusesCard(
      onViewPromos: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PromotionsPage()),
        );
      },
    );
  }
}
