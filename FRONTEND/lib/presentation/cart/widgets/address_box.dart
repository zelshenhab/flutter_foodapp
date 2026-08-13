import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/branches/branch_cubit.dart';
import 'package:flutter_foodapp/core/branches/restaurant_branch.dart';
import 'package:flutter_foodapp/presentation/common/widgets/branch_selector.dart';

class AddressBox extends StatelessWidget {
  const AddressBox({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BranchCubit, RestaurantBranch>(
      builder: (context, branch) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: const BranchSelectorTile(),
          ),
        );
      },
    );
  }
}
