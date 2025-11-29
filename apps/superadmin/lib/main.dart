import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'auth_guard.dart';
import 'login_page.dart';
import 'admin_profile.dart';
import 'user_management.dart';
import 'analytics_page.dart';
import 'responses_page.dart';
import 'survey_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔥 Initialize Supabase HERE
  await Supabase.initialize(
    url: 'https://suectobciubzwzvaxjmp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN1ZWN0b2JjaXViend6dmF4am1wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMxMjgyMzgsImV4cCI6MjA3ODcwNDIzOH0.d9ZkXs_Knw9Gs4GyYaxNM_P4c1XTkTDWnjNB0yfmyLU',
  );
  // In debug mode, ensure common debug paint overlays are turned off.
  // This runs only in debug (asserts are disabled in release/profile builds).
  assert(() {
    debugPaintSizeEnabled = false;
    debugPaintBaselinesEnabled = false;
    debugPaintPointersEnabled = false;
    debugPaintLayerBordersEnabled = false;
    debugRepaintRainbowEnabled = false;
    return true;
  }());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  Route<dynamic> buildRoute(RouteSettings settings) {
      Widget page;
      switch (settings.name) {
        case '/':
          page = const LoginPage();
          break;
        case '/admin/profile':
          page = AuthGuard(child: const AdminProfilePage());
          break;
        case '/admin/users':
          page = AuthGuard(child: const UserManagementPage());
          break;
        case '/admin/analytics':
          page = AuthGuard(child: const AnalyticsPage());
          break;
        case '/admin/responses':
          page = AuthGuard(child: const ResponsesPage());
          break;
        case '/admin/survey':
          page = AuthGuard(child: const SurveyPage());
          break;
        default:
          page = const LoginPage();
      }

      return PageRouteBuilder(
        settings: settings,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, animation, secondaryAnimation) => page,
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          // Simple fade transition
          final fadeAnimation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
          return FadeTransition(opacity: fadeAnimation, child: child);
        },
      );
    }

    return MaterialApp(
      title: 'ARTA ADMIN',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
        // Set Poppins as the default app font. Individual widgets can
        // still override this (e.g. the left header uses Racing Sans One).
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      initialRoute: '/',
  onGenerateRoute: (settings) => buildRoute(settings),
      debugShowCheckedModeBanner: false,
    );
  }
}