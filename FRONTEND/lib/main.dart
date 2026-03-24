import 'package:flutter/material.dart';
import 'core/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/api_client.dart';
import 'presentation/auth/pages/login_info_page.dart';
import 'presentation/root/app_shell.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupInterceptors(navigatorKey: appNavigatorKey);

  try {
    await Supabase.initialize(
      url: 'https://nwaphgvmxtaalyxpgfdt.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im53YXBoZ3ZteHRhYWx5eHBnZmR0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2MTQzNjMsImV4cCI6MjA3NjE5MDM2M30.MgK0G5bmvZJ6yT1vNnzn4Qz0OiIhtWde2kLx7KAG3wo',
    ).timeout(const Duration(seconds: 10));
  } catch (e) {
    debugPrint("Supabase init failed: $e");
  }
  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF121212);
    const surface = Color(0xFF1E1E1E);
    const text = Color(0xFFEDEDED);
    const accent = Color.fromARGB(255, 199, 160, 34);

    return MaterialApp(
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Адам и Ева',

      routes: {
        '/login': (_) => const LoginInfoPage(),
        '/home': (_) => const AppShell(),
      },

      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bg,
        cardColor: const Color(0xFF1A1A1A),
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accent,
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

      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

 Future<void> _initialize() async {
  const storage = FlutterSecureStorage();

  try {
    final token = await storage.read(key: 'auth_token');

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // 👇 Guest mode
      Navigator.pushReplacementNamed(context, '/home');
    }
  } catch (e) {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }
}

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}