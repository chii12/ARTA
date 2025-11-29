import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_page.dart';
import 'admin_profile.dart';
import 'user_management.dart';
import 'responses_page.dart';
import 'analytics_page.dart';
import 'survey_page.dart';
import 'qr_code_page.dart';
import 'public_survey_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Initialize Supabase HERE
  await Supabase.initialize(
    url: 'https://suectobciubzwzvaxjmp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN1ZWN0b2JjaXViend6dmF4am1wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMxMjgyMzgsImV4cCI6MjA3ODcwNDIzOH0.d9ZkXs_Knw9Gs4GyYaxNM_P4c1XTkTDWnjNB0yfmyLU',
  );

  // Debug painting OFF
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
      
      // Handle survey route with ID parameter
      if (settings.name?.startsWith('/survey/') == true) {
        final surveyId = settings.name!.substring(8);
        page = PublicSurveyPage(surveyId: surveyId);
      } else {
        switch (settings.name) {
          case '/':
            page = const LoginPage();
            break;
          case '/admin/profile':
            page = const AdminProfilePage();
            break;
          case '/admin/users':
            page = const UserManagementPage();
            break;
          case '/admin/responses':
            page = const ResponsesPage();
            break;
          case '/admin/survey':
            page = const SurveyPage();
            break;
          case '/admin/analytics':
            page = const AnalyticsPage();  
            break;
          case '/admin/qr':
            page = const QRCodePage();
            break;
          default:
            page = const LoginPage();
        }
      }

      return PageRouteBuilder(
        settings: settings,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, animation, secondaryAnimation) => page,
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final fadeAnimation =
              CurvedAnimation(parent: animation, curve: Curves.easeInOut);
          return FadeTransition(opacity: fadeAnimation, child: child);
        },
      );
    }

    return MaterialApp(
      title: 'ARTA ADMIN',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) => buildRoute(settings),
      debugShowCheckedModeBanner: false,
    );
  }
}
