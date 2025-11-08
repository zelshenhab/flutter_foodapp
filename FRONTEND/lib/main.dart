import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/api_client.dart';
import 'presentation/auth/pages/login_info_page.dart';
import 'presentation/root/app_shell.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nwaphgvmxtaalyxpgfdt.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im53YXBoZ3ZteHRhYWx5eHBnZmR0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2MTQzNjMsImV4cCI6MjA3NjE5MDM2M30.MgK0G5bmvZJ6yT1vNnzn4Qz0OiIhtWde2kLx7KAG3wo',
  );

  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'auth_token');

  // 🧩 Setup interceptors (pass global navigator)
  setupInterceptors(navigatorKey: appNavigatorKey);

  // Add token to headers if valid
  if (token != null && token.isNotEmpty) {
    dio.options.headers['Authorization'] = 'Bearer $token';
    debugPrint('✅ Token restored from secure storage');
  } else {
    debugPrint('ℹ️ No token found — login required');
  }

  runApp(MyApp(isLoggedIn: token != null && token.isNotEmpty));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF121212);
    const surface = Color(0xFF1E1E1E);
    const text = Color(0xFFEDEDED);
    const accent = Color(0xFFFF7A00);

    return MaterialApp(
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Адам и Ева',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bg,
        cardColor: const Color(0xFF1A1A1A),
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accent,
          background: bg,
          surface: surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: text,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: text),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: accent,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: false,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: text,
              displayColor: text,
            ),
      ),
      initialRoute: isLoggedIn ? '/app' : '/login',
      routes: {
        '/login': (_) => const LoginInfoPage(),
        '/app': (_) => const AppShell(),
      },
    );
  }
}
