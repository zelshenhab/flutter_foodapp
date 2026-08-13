import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/branches/branch_cubit.dart';
import 'package:flutter_foodapp/core/branches/restaurant_branch.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
import 'package:maps_launcher/maps_launcher.dart';

Future<void> showBranchPicker(BuildContext context) async {
  final l10n = context.l10n;
  final cubit = context.read<BranchCubit>();
  final currentId = cubit.state.id;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF1A1A1A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Text(
                  l10n.selectRestaurantAddress,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              for (final branch in RestaurantBranch.all)
                ListTile(
                  leading: Icon(
                    branch.id == currentId
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: const Color.fromARGB(255, 199, 160, 34),
                  ),
                  title: Text(
                    branch.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    branch.street,
                    style: const TextStyle(color: Color(0xFFA7A7A7)),
                  ),
                  trailing: IconButton(
                    tooltip: l10n.openInMaps,
                    icon: const Icon(Icons.map_outlined,
                        color: Color(0xFFA7A7A7)),
                    onPressed: () =>
                        MapsLauncher.launchQuery(branch.mapQuery),
                  ),
                  onTap: () async {
                    await cubit.select(branch.id);
                    if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// Compact tappable chip used in menu header / cart.
class BranchSelectorTile extends StatelessWidget {
  final bool compact;

  const BranchSelectorTile({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFFA7A7A7);
    const chipBg = Color(0xFF1E1E1E);
    const border = Color(0xFF2A2A2A);
    const accent = Color.fromARGB(255, 199, 160, 34);

    return BlocBuilder<BranchCubit, RestaurantBranch>(
      builder: (context, branch) {
        if (compact) {
          return GestureDetector(
            onTap: () => showBranchPicker(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: muted),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      branch.fullAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: muted, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 16, color: accent),
                ],
              ),
            ),
          );
        }

        return ListTile(
          leading: const Icon(Icons.storefront, color: accent),
          title: Text(
            branch.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            branch.street,
            style: const TextStyle(color: muted),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showBranchPicker(context),
        );
      },
    );
  }
}
