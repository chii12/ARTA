import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'landing_page.dart';
import 'landing_page_desktop.dart';
import 'qr_scanner_page.dart';
import 'dynamic_survey_page.dart';
import 'saved_surveys_page.dart';
import 'services/qr_service.dart';
import 'services/database_init.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://suectobciubzwzvaxjmp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN1ZWN0b2JjaXViend6dmF4am1wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMxMjgyMzgsImV4cCI6MjA3ODcwNDIzOH0.d9ZkXs_Knw9Gs4GyYaxNM_P4c1XTkTDWnjNB0yfmyLU',
  );
  
  // Initialize default database entries
  await DatabaseInit.ensureDefaultData();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Helper to determine if we're on desktop
  bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARTA User',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Handle survey URLs from QR codes or deep links
        if (settings.name?.startsWith('/survey/') == true) {
          final surveyId = settings.name!.substring(8);
          return MaterialPageRoute(
            builder: (_) => FutureBuilder<Map<String, dynamic>?>(
              future: QRService.fetchSurveyFromQR('https://yourapp.com/survey/$surveyId'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                final surveyData = snapshot.data ?? QRService.getDefaultSurveyData();
                return DynamicSurveyPage(
                  surveyData: surveyData,
                  questions: snapshot.data != null 
                    ? List<Map<String, dynamic>>.from(snapshot.data!['template']['questions'])
                    : QRService.getDefaultQuestions(),
                );
              },
            ),
          );
        }
        
        // Handle artasurvey:// scheme
        if (settings.name?.startsWith('artasurvey://') == true) {
          final url = settings.name!;
          return MaterialPageRoute(
            builder: (_) => FutureBuilder<Map<String, dynamic>?>(
              future: QRService.fetchSurveyFromQR(url),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                final surveyData = snapshot.data ?? QRService.getDefaultSurveyData();
                return DynamicSurveyPage(
                  surveyData: surveyData,
                  questions: snapshot.data != null 
                    ? List<Map<String, dynamic>>.from(snapshot.data!['template']['questions'])
                    : QRService.getDefaultQuestions(),
                );
              },
            ),
          );
        }
        
        // Default routes
        switch (settings.name) {
          case '/qr':
            return MaterialPageRoute(builder: (_) => const QRScannerPage());
          case '/saved':
            return MaterialPageRoute(builder: (_) => const SavedSurveysPage());
          default:
            return MaterialPageRoute(
              builder: (_) => LayoutBuilder(
                builder: (context, constraints) {
                  if (isDesktop || constraints.maxWidth > 900) {
                    return const LandingPageDesktop();
                  }
                  return const LandingPage();
                },
              ),
            );
        }
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
