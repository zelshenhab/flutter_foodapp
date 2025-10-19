import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/repos/menu_repo.dart';
import 'data/repos/orders_repo.dart';
import 'data/repos/promos_repo.dart';
import 'data/repos/tickets_repo.dart';
import 'presentation/common/admin_theme.dart';
import 'presentation/root/admin_shell.dart';

// DATA (غيّر المسارات لو أنت حاطط data/ داخل lib_admin/)
import 'data/admin_api_client.dart';
import 'data/repos/users_repo.dart';

// BLOCS
import 'presentation/users/bloc/users_bloc.dart';
import 'presentation/users/bloc/users_event.dart';

import 'presentation/orders/bloc/orders_bloc.dart';
import 'presentation/orders/bloc/orders_event.dart';

import 'presentation/menu/bloc/menu_admin_bloc.dart';
import 'presentation/menu/bloc/menu_admin_event.dart';

import 'presentation/promos/bloc/promos_bloc.dart';
import 'presentation/promos/bloc/promos_event.dart';

import 'presentation/tickets/bloc/tickets_bloc.dart';
import 'presentation/tickets/bloc/tickets_event.dart';

import 'presentation/settings/bloc/settings_cubit.dart';

void main() {
  final api = AdminApiClient(baseUrl: 'http://localhost:3000', token: null);
  runApp(AdminApp(api: api));
}

class AdminApp extends StatelessWidget {
  final AdminApiClient api;
  const AdminApp({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UsersRepo>(create: (_) => UsersRepo(api)),
        // OrdersRepo is abstract; replace the throw with a concrete implementation, e.g. OrdersRepoImpl(api)
        RepositoryProvider<OrdersRepo>(
          create: (_) => throw UnimplementedError(
            'Provide a concrete OrdersRepo implementation (e.g. OrdersRepoImpl)',
          ),
        ),
        RepositoryProvider<MenuRepo>(create: (_) => MenuRepo(api)),
        RepositoryProvider<PromosRepo>(create: (_) => PromosRepo(api)),
        RepositoryProvider<TicketsRepo>(create: (_) => TicketsRepo(api)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<UsersBloc>(
            create: (ctx) =>
                UsersBloc(ctx.read<UsersRepo>())..add(const UsersLoaded()),
          ),
          BlocProvider<OrdersBloc>(
            create: (ctx) =>
                OrdersBloc(ctx.read<OrdersRepo>())..add(const OrdersLoaded()),
          ),
          BlocProvider<MenuAdminBloc>(
            create: (ctx) =>
                MenuAdminBloc(ctx.read<MenuRepo>())
                  ..add(const MenuAdminLoaded()),
          ),
          BlocProvider<PromosBloc>(
            create: (ctx) =>
                PromosBloc(ctx.read<PromosRepo>())..add(const PromosLoaded()),
          ),
          BlocProvider<TicketsBloc>(
            create: (ctx) =>
                TicketsBloc(ctx.read<TicketsRepo>())
                  ..add(const TicketsLoaded()),
          ),
          BlocProvider<SettingsCubit>(create: (_) => SettingsCubit()),
        ],
        child: MaterialApp(
          title: 'Admin • Адам и Ева',
          debugShowCheckedModeBanner: false,
          theme: buildAdminTheme(),
          home: const AdminShell(),
        ),
      ),
    );
  }
}
