import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_foodapp/core/services/vpn_service.dart';
import 'core/l10n/app_localizations.dart';
import 'core/l10n/locale_cubit.dart';
import 'core/l10n/tt_material_fallback.dart';
import 'core/branches/branch_cubit.dart';
import 'core/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/api_client.dart';
import 'presentation/auth/pages/login_info_page.dart';
import 'presentation/common/widgets/app_toast.dart';
import 'presentation/root/app_shell.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/auth/bloc/auth_event.dart';
import 'presentation/auth/data/real_auth_service.dart';

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

  final localeCubit = LocaleCubit();
  await localeCubit.load();

  final branchCubit = BranchCubit();
  await branchCubit.load();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(RealAuthService())..add(AuthStarted()),
        ),
        BlocProvider.value(value: localeCubit),
        BlocProvider.value(value: branchCubit),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF121212);
    const surface = Color(0xFF1E1E1E);
    const text = Color(0xFFEDEDED);
    const accent = Color.fromARGB(255, 199, 160, 34);

    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return MaterialApp(
          navigatorKey: appNavigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Adam & Eve',
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            TtMaterialLocalizationsDelegate(),
            TtCupertinoLocalizationsDelegate(),
            TtWidgetsLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
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
      },
    );
  }
}

// main.dart (updated SplashScreen)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isChecking = true;
  bool _showVpnDialog = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // First, check network status
    final networkStatus = await VpnService.checkNetworkStatus();

    if (!mounted) return;

    // If no internet or VPN issue, show dialog
    if (!networkStatus['canReachSupabase']!) {
      setState(() {
        _isChecking = false;
        _showVpnDialog = true;
      });
      return;
    }

    // If VPN is active, show info dialog (optional)
    if (networkStatus['isVpn']!) {
      setState(() {
        _isChecking = false;
        _showVpnDialog = true;
      });
      return;
    }

    // Proceed with normal flow
    await _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    const storage = FlutterSecureStorage();

    try {
      final refreshToken = await storage.read(key: 'refresh_token');
      final accessToken = await storage.read(key: 'auth_token');

      if (!mounted) return;

      // Renew access token on cold start when we still have a refresh token.
      if (refreshToken != null && refreshToken.isNotEmpty) {
        final ok = await ensureFreshSession();
        if (!mounted) return;
        if (ok) {
          Navigator.pushReplacementNamed(context, '/home');
          return;
        }
        // Refresh failed — fall through to guest/home without forcing login
        // if we somehow still have a usable access token; otherwise home as guest.
      }

      if (accessToken != null && accessToken.isNotEmpty) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Guest mode
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _showVpnRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final l10n = context.l10n;
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              Text(l10n.vpnRequired),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.vpnRequiredBody,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.vpnCheckHint,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.vpnCheckInternet,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.vpnEnableRestart,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.vpnTryLater,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Try again
                Navigator.pop(context);
                setState(() {
                  _isChecking = true;
                  _showVpnDialog = false;
                });
                _initialize();
              },
              child: Text(l10n.checkAgain),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Close app
                Navigator.pop(context);
                // Optionally show a message before closing
                AppToast.info(context, l10n.pleaseEnableVpnRestart);
                // Delay exit to show snackbar
                Future.delayed(const Duration(seconds: 1), () {
                  if (!context.mounted) return;
                  // For Android
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  // For iOS, we can't force close, but we can show alert
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              icon: const Icon(Icons.close),
              label: Text(l10n.closeApp),
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Show VPN dialog if needed
    if (_showVpnDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showVpnRequiredDialog();
      });
      _showVpnDialog = false; // Prevent multiple dialogs
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or name
            Text(
              l10n.appName,
              style: const TextStyle(
                color: Color.fromARGB(255, 199, 160, 34),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.foodDelivery,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 40),
            if (_isChecking) ...[
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 199, 160, 34),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.checkingConnection,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
            if (_showVpnDialog) ...[
              // Auto-show dialog when _showVpnDialog is true
              // We use a callback to show it after build
            ],
          ],
        ),
      ),
    );
  }
}
