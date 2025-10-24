import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/repos/menu_repo_supabase.dart' as menu_repo_sb;

// Menu
import 'presentation/menu/bloc/menu_admin_bloc.dart' as admin_menu_bloc;
import 'presentation/menu/bloc/menu_admin_event.dart' as admin_menu_event;

import 'presentation/common/admin_theme.dart';
import 'presentation/root/admin_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nwaphgvmxtaalyxpgfdt.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im53YXBoZ3ZteHRhYWx5eHBnZmR0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2MTQzNjMsImV4cCI6MjA3NjE5MDM2M30.2XsCt3ZIhyTciJrWKmer6-YAWM9uMSu0IyVdrZeVqzM',
  );

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<menu_repo_sb.MenuRepoSupabase>(
      create: (_) => menu_repo_sb.MenuRepoSupabase(),
      child: BlocProvider<admin_menu_bloc.MenuAdminBloc>(
        create: (ctx) => admin_menu_bloc.MenuAdminBloc.withSupabase(
          repo: ctx.read<menu_repo_sb.MenuRepoSupabase>(),
        )..add(const admin_menu_event.MenuAdminLoaded()),
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
