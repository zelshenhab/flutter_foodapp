import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
import 'package:flutter_foodapp/core/auth/auth_session.dart';
import 'package:flutter_foodapp/presentation/common/widgets/app_toast.dart';
import 'package:flutter_foodapp/presentation/common/widgets/guest_browse_banner.dart';
import 'package:flutter_foodapp/presentation/common/widgets/login_required_dialog.dart';
import 'package:flutter_foodapp/presentation/cart/bloc/cart_bloc.dart';
import 'package:flutter_foodapp/presentation/cart/bloc/cart_event.dart';

// BLoC المنيو
import '../bloc/menu_bloc.dart';
import '../bloc/menu_event.dart';
import '../bloc/menu_state.dart';

// Widgets
import '../widgets/menu_header.dart';
import '../widgets/menu_search_bar.dart';
import '../widgets/promo_banner.dart';
import '../widgets/category_icon_strip.dart';
import '../widgets/menu_item_tile.dart';

// للربط مع السلة

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<MenuBloc>().add(MenuRefreshed());
          },
          child: BlocBuilder<MenuBloc, MenuState>(
            builder: (context, state) {
              final iconMap = <String, String>{
               /* 'shawarma': 'assets/images/Chicken-Shawarma-8.jpg',
                'box': 'assets/images/Chicken-Shawarma-8.jpg',
                'roll': 'assets/images/Chicken-Shawarma-8.jpg',
                'eurobox': 'assets/images/Chicken-Shawarma-8.jpg',
                'pizza': 'assets/images/Chicken-Shawarma-8.jpg',
                'salads': 'assets/images/Chicken-Shawarma-8.jpg',
                'main': 'assets/images/Chicken-Shawarma-8.jpg',
                'breakfast': 'assets/images/Chicken-Shawarma-8.jpg',
                'sauces': 'assets/images/Chicken-Shawarma-8.jpg',*/
                'bakhlava-box': 'assets/images/baklava-walnut-assorted.jpg',
                'bakhlava-vec': 'assets/images/baklava-walnut-assorted.jpg',
                'cookies': 'assets/images/arabic-cookies.jpg',
                'assorted-sweets': 'assets/images/assorted-gnezdo-12pcs.jpg',
                'gift-boxes': 'assets/images/gift-box-walnut-900g.jpg',
                'gnezdo': 'assets/images/gnezdo-nuts.jpg',
                'shabiyat': 'assets/images/shabiyat.jpg',
                'kataifi': 'assets/images/kataifi-pistachio.jpg',
                'triangles-rolls': 'assets/images/mini-triangle-walnut.jpg',
                'luxury-arabic-sweets': 'assets/images/luxury-arabic-sweets.jpg',
                'drinks': 'assets/images/luxury-arabic-sweets.jpg'
              };

              if (state.loading && state.items.isEmpty) {
                return const _MenuLoadingSliver();
              }

              final l10n = context.l10n;

              if (state.error != null) {
                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n.menuLoadError),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () =>
                                  context.read<MenuBloc>().add(MenuStarted()),
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: MenuHeader()),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  const SliverToBoxAdapter(child: GuestBrowseBanner()),
                  SliverToBoxAdapter(
                      child: MenuSearchBar(
                        onChanged: (q) {
                          context.read<MenuBloc>().add(MenuSearchChanged(q));
                        },
                      ),
                    ),
                  const SliverToBoxAdapter(child: PromoBanner()),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        l10n.categories,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  if (state.categories.isNotEmpty)
                    SliverToBoxAdapter(
                      child: CategoryIconStrip(
                        categories: state.categories,
                        selectedId: state.selectedCategoryId,
                        iconAssetByCategoryId: iconMap,
                        subtitleByCategoryId: {
                          'bakhlava-box': context.l10n.unitBox,
                          'bakhlava-vec': context.l10n.unitWeight,
                        },
                        onSelected: (id) => context
                            .read<MenuBloc>()
                            .add(MenuCategorySelected(id)),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  const SliverToBoxAdapter(
                    child: Divider(height: 1, color: Color(0xFF2A2A2A)),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.all(12),
                    sliver: SliverList.separated(
                      itemBuilder: (context, i) {
                        final item = state.items[i];
                        // inside SliverList.separated itemBuilder:
                        return MenuItemTile(
                          item: item,
                          onAdd: () async {
                            if (!await AuthSession.isLoggedIn()) {
                              if (!context.mounted) return;
                              await showLoginRequiredDialog(
                                context,
                                message: context.l10n.loginRequiredAddToCart,
                              );
                              return;
                            }

                            final numericId =
                                item.serverId ?? int.tryParse(item.id);
                            if (numericId == null) {
                              if (!context.mounted) return;
                              AppToast.error(
                                context,
                                context.l10n.itemUnavailable(item.id),
                              );
                              return;
                            }

                            if (!context.mounted) return;
                            context.read<CartBloc>().add(
                              CartItemAdded(item, quantity: 1),
                            );
                          },
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemCount: state.items.length,
                    ),
                  ),

                  if (state.loading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ====== Skeleton أثناء التحميل ======
class _MenuLoadingSliver extends StatelessWidget {
  const _MenuLoadingSliver();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList.builder(
            itemCount: 6,
            itemBuilder: (_, __) => Container(
              height: 98,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
