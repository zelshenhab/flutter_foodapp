import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/admin_api_client.dart';

// repos
import 'data/repos/analytics_repo.dart';
import 'data/repos/menu_repo.dart';
import 'data/repos/orders_repo.dart';
import 'data/repos/promos_repo.dart';
import 'data/repos/users_repo.dart';
import 'data/repos/tickets_repo.dart';
import 'data/repos/settings_repo.dart';

// blocs
import 'presentation/dashboard/bloc/analytics_bloc.dart';
import 'presentation/dashboard/bloc/analytics_event.dart';
import 'presentation/menu/bloc/menu_admin_bloc.dart';
import 'presentation/menu/bloc/menu_admin_event.dart';

import 'presentation/users/bloc/users_bloc.dart';
import 'presentation/users/bloc/users_event.dart';

import 'presentation/common/admin_theme.dart';
import 'presentation/root/admin_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// IMPORTANT:
  /// Web uses "localhost"
  /// Emulator uses "10.0.2.2"
  final api = AdminApiClient(
    baseUrl: kIsWeb
        ? "http://localhost:4000/api/admin"
        : "http://10.0.2.2:4000/api/admin",
  );

  runApp(AdminApp(api: api));
}

class AdminApp extends StatelessWidget {
  final AdminApiClient api;

  const AdminApp({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<MenuRepo>(create: (_) => MenuRepo(api)),
        RepositoryProvider<OrdersRepo>(create: (_) => OrdersRepo(api)),
        RepositoryProvider<PromosRepo>(create: (_) => PromosRepo(api)),
        RepositoryProvider<UsersRepo>(create: (_) => UsersRepo(api)),
        RepositoryProvider<TicketsRepo>(create: (_) => TicketsRepo(api)),
        RepositoryProvider<SettingsRepo>(create: (_) => SettingsRepo(api)),
        RepositoryProvider<AnalyticsRepo>(create: (_) => AnalyticsRepo(api)),
      ],
      child: MultiBlocProvider(
        providers: [
          /// MENU
          BlocProvider<MenuAdminBloc>(
            create: (ctx) => MenuAdminBloc(
              repo: ctx.read<MenuRepo>(),
            )..add(const MenuAdminLoaded()),
          ),

          /// USERS - pagination-enabled BLoC
          BlocProvider<UsersBloc>(
            create: (ctx) => UsersBloc(
              ctx.read<UsersRepo>(),
            )..add(const UsersLoaded()),
          ),

          BlocProvider<AnalyticsBloc>(
            create: (ctx) => AnalyticsBloc(
              ctx.read<AnalyticsRepo>(),
            )..add(const AnalyticsLoad()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Admin Dashboard",
          theme: buildAdminTheme(),
          home: const AdminShell(),
        ),
      ),
    );
  }
}
