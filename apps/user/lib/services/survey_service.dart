import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Service class for handling survey data
/// Ready for backend API integration
class SurveyService {
  static const String _storageKey = 'arta_surveys';
  
  /// Data structure for a complete survey response
  /// This structure is ready to be sent to a backend API
  static Map<String, dynamic> createSurveyResponse({
    required String name,
    required String clientType,
    required String sex,
    required String date,
    required String age,
    required String region,
    required String service,
    required String? cc1,
    required String? cc2,
    required String? cc3,
    required String? sqd0,
    required String? sqd1,
    required String? sqd2,
    required String? sqd3,
    required String? sqd4,
    required String? sqd5,
    required String? sqd6,
    required String? sqd7,
    required String? sqd8,
    String? suggestions,
    String? email,
    String? departmentId,
  }) {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'departmentId': departmentId ?? '00000000-0000-0000-0000-000000000000',
      'personalInfo': {
        'name': name,
        'clientType': clientType,
        'sex': sex,
        'date': date,
        'age': age,
        'region': region,
        'serviceAvailed': service,
      },
      'ccQuestions': {
        'cc1': cc1,
        'cc2': cc2,
        'cc3': cc3,
      },
      'sqdQuestions': {
        'sqd0': sqd0,
        'sqd1': sqd1,
        'sqd2': sqd2,
        'sqd3': sqd3,
        'sqd4': sqd4,
        'sqd5': sqd5,
        'sqd6': sqd6,
        'sqd7': sqd7,
        'sqd8': sqd8,
      },
      'feedback': {
        'suggestions': suggestions ?? '',
        'email': email ?? '',
      },
    };
  }

  /// Save survey response locally (offline storage)
  /// TODO: Replace with API call to backend when available
  static Future<bool> saveSurveyLocal(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(_storageKey);
      List<dynamic> list = existing != null
          ? jsonDecode(existing) as List<dynamic>
          : <dynamic>[];
      
      // Add timestamp if not present
      if (!data.containsKey('timestamp')) {
        data['timestamp'] = DateTime.now().toIso8601String();
      }
      
      list.add(data);
      await prefs.setString(_storageKey, jsonEncode(list));
      return true;
    } catch (e) {
      print('Error saving survey locally: $e');
      return false;
    }
  }

  /// Get all locally stored surveys
  /// Useful for syncing with backend or viewing pending submissions
  static Future<List<Map<String, dynamic>>> getLocalSurveys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(_storageKey);
      if (existing == null) return [];
      
      final List<dynamic> list = jsonDecode(existing) as List<dynamic>;
      return list.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error getting local surveys: $e');
      return [];
    }
  }

  /// Clear all local surveys
  /// Use after successful sync with backend
  static Future<bool> clearLocalSurveys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      return true;
    } catch (e) {
      print('Error clearing local surveys: $e');
      return false;
    }
  }

  /// Count pending surveys
  static Future<int> getPendingSurveyCount() async {
    final surveys = await getLocalSurveys();
    return surveys.length;
  }

  // ============================================
  // BACKEND API INTEGRATION SECTION
  // ============================================
  // TODO: Implement these methods when backend API is ready
  
  /// Submit survey to Supabase database
  static Future<bool> submitSurveyToAPI(Map<String, dynamic> data) async {
    try {
      final supabase = Supabase.instance.client;
      const uuid = Uuid();
      
      print('🔄 Starting survey submission...');
      print('📊 Survey data: $data');
      
      // Get department ID from survey data (from QR code) or fetch first available
      String departmentId = data['departmentId'] ?? '00000000-0000-0000-0000-000000000000';
      
      if (departmentId == '00000000-0000-0000-0000-000000000000' || data['departmentId'] == null) {
        final deptResponse = await supabase.from('departments').select('department_id').limit(1).maybeSingle();
        if (deptResponse != null) {
          departmentId = deptResponse['department_id'];
        }
      }
      print('🏢 Department ID: $departmentId');
      
      // Create respondent
      final respondentId = uuid.v4();
      await supabase.from('respondents').insert({
        'respondent_id': respondentId,
        'client_type': data['personalInfo']['clientType'],
        'name': data['personalInfo']['name'],
        'age': int.tryParse(data['personalInfo']['age']) ?? 0,
        'sex': data['personalInfo']['sex'],
        'region_of_residence': data['personalInfo']['region'],
      });

      // Get or create survey for the specific department
      final surveyResponse = await supabase
          .from('surveys')
          .select()
          .eq('title', 'ARTA Customer Satisfaction Survey')
          .eq('department_id', departmentId)
          .maybeSingle();
      
      String surveyId;
      if (surveyResponse == null) {
        surveyId = uuid.v4();
        await supabase.from('surveys').insert({
          'survey_id': surveyId,
          'title': 'ARTA Customer Satisfaction Survey',
          'department_id': departmentId,
          'user_created_by': (await supabase.from('users').select('user_id').eq('department_id', departmentId).limit(1).single())['user_id'],
        });
      } else {
        surveyId = surveyResponse['survey_id'];
      }

      // Create service if provided (linked to correct department)
      String? serviceId;
      if (data['personalInfo']['serviceAvailed']?.isNotEmpty == true) {
        serviceId = uuid.v4();
        await supabase.from('services').insert({
          'service_id': serviceId,
          'service_name': data['personalInfo']['serviceAvailed'],
          'department_id': departmentId,
        });
      }

      // Create response
      final responseId = uuid.v4();
      await supabase.from('responses').insert({
        'response_id': responseId,
        'survey_id': surveyId,
        'respondent_id': respondentId,
        'service_availed_id': serviceId,
      });

      // Create questions and answers
      final questions = [
        {'code': 'CC1', 'text': 'Which of the following best describes your awareness of a CC?', 'type': 'multiple_choice'},
        {'code': 'CC2', 'text': 'If aware of CC, would you say that the CC of this office was...?', 'type': 'multiple_choice'},
        {'code': 'CC3', 'text': 'How much did the CC help you in your transaction?', 'type': 'multiple_choice'},
        {'code': 'SQD0', 'text': 'I am satisfied with the service that I availed', 'type': 'rating'},
        {'code': 'SQD1', 'text': 'I spent a reasonable amount of time for my transaction', 'type': 'rating'},
        {'code': 'SQD2', 'text': 'The office followed the transaction\'s requirements and steps', 'type': 'rating'},
        {'code': 'SQD3', 'text': 'The steps I needed to do for my transaction were easy and simple', 'type': 'rating'},
        {'code': 'SQD4', 'text': 'I easily found information about my transaction', 'type': 'rating'},
        {'code': 'SQD5', 'text': 'I paid a reasonable amount of fees for my transaction', 'type': 'rating'},
        {'code': 'SQD6', 'text': 'I feel the office was fair to everyone', 'type': 'rating'},
        {'code': 'SQD7', 'text': 'I was treated courteously by the staff', 'type': 'rating'},
        {'code': 'SQD8', 'text': 'I got what I needed from the government office', 'type': 'rating'},
      ];

      for (final q in questions) {
        // Check if question exists
        final existingQuestion = await supabase
            .from('questions')
            .select()
            .eq('survey_id', surveyId)
            .eq('question_code', q['code']!)
            .maybeSingle();
        
        String questionId;
        if (existingQuestion == null) {
          questionId = uuid.v4();
          await supabase.from('questions').insert({
            'question_id': questionId,
            'survey_id': surveyId,
            'question_code': q['code'],
            'question_text': q['text'],
            'question_type': q['type'],
          });
        } else {
          questionId = existingQuestion['question_id'];
        }

        // Insert answer if exists - fix key case mismatch
        final answerValue = q['code']!.startsWith('CC') 
            ? data['ccQuestions'][q['code']!.toLowerCase()]
            : data['sqdQuestions'][q['code']!.toLowerCase()];
        
        print('Question ${q['code']}: $answerValue');
        
        if (answerValue != null) {
          int? ratingValue;
          String? textAnswer;
          
          // Convert satisfaction ratings to numeric values
          if (answerValue is String) {
            switch (answerValue) {
              case 'STRONGLY AGREE': ratingValue = 5; break;
              case 'AGREE': ratingValue = 4; break;
              case 'NEITHER AGREE NOR DISAGREE': ratingValue = 3; break;
              case 'DISAGREE': ratingValue = 2; break;
              case 'STRONGLY DISAGREE': ratingValue = 1; break;
              case 'NOT APPLICABLE': ratingValue = 0; break;
              default: textAnswer = answerValue;
            }
          } else {
            textAnswer = answerValue.toString();
          }
          
          await supabase.from('response_answers').insert({
            'answer_id': uuid.v4(),
            'response_id': responseId,
            'question_id': questionId,
            'text_answer': textAnswer,
            'rating_value': ratingValue,
          });
          print('✅ Answer inserted for ${q['code']}');
        }
      }

      // Save suggestions if provided
      if (data['feedback']['suggestions']?.isNotEmpty == true || 
          data['feedback']['email']?.isNotEmpty == true) {
        await supabase.from('suggestions').insert({
          'suggestion_id': uuid.v4(),
          'response_id': responseId,
          'comment_text': data['feedback']['suggestions'],
          'email_optional': data['feedback']['email'],
        });
      }

      // Also save locally as backup
      await saveSurveyLocal(data);
      
      print('✅ Survey submitted to database successfully!');
      return true;
    } catch (e) {
      print('❌ Database submission failed: $e');
      // Fallback to local storage
      return await saveSurveyLocal(data);
    }
  }

  /// Sync all pending surveys with backend
  static Future<bool> syncPendingSurveys() async {
    try {
      final surveys = await getLocalSurveys();
      if (surveys.isEmpty) return true;
      
      bool allSuccess = true;
      for (var survey in surveys) {
        final success = await submitSurveyToAPI(survey);
        if (!success) allSuccess = false;
      }
      
      if (allSuccess) {
        await clearLocalSurveys();
      }
      return allSuccess;
    } catch (e) {
      print('Error syncing surveys: $e');
      return false;
    }
  }

  /// Check if device has internet connection
  /// Use before attempting API calls
  static Future<bool> hasInternetConnection() async {
    // TODO: Implement connectivity check
    // You can use connectivity_plus package
    return true;
  }
}
