import 'package:http/http.dart' as http;
import 'dart:convert';

class QRService {
  static Future<Map<String, dynamic>?> fetchSurveyFromQR(String qrData) async {
    try {
      // Extract survey ID from QR code URL
      final uri = Uri.parse(qrData);
      final surveyId = uri.pathSegments.last;
      
      // Fetch survey data with department info from admin's Supabase
      final response = await http.get(
        Uri.parse('https://suectobciubzwzvaxjmp.supabase.co/rest/v1/survey_templates?id=eq.$surveyId&select=*,department_id'),
        headers: {
          'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN1ZWN0b2JjaXViend6dmF4am1wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMxMjgyMzgsImV4cCI6MjA3ODcwNDIzOH0.d9ZkXs_Knw9Gs4GyYaxNM_P4c1XTkTDWnjNB0yfmyLU',
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN1ZWN0b2JjaXViend6dmF4am1wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMxMjgyMzgsImV4cCI6MjA3ODcwNDIzOH0.d9ZkXs_Knw9Gs4GyYaxNM_P4c1XTkTDWnjNB0yfmyLU',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data.first;
        }
      }
    } catch (e) {
      print('Error fetching survey: $e');
    }
    return null;
  }
  
  static List<Map<String, dynamic>> getDefaultQuestions() {
    return [
      {'code': 'CC1', 'text': 'Which of the following best describes your awareness of a CC?', 'type': 'multiple_choice', 'options': ['I know what a CC is and I saw this office\'s CC', 'I know what a CC is but I did NOT see this office\'s CC', 'I learned of the CC only when I saw this office\'s CC', 'I do not know what a CC is and I did not see one in this office']},
      {'code': 'CC2', 'text': 'If aware of CC (answered 1-3 in CC1), would you say that the CC of this office was...?', 'type': 'multiple_choice', 'options': ['Easy to see', 'Somewhat easy to see', 'Difficult to see', 'Not visible at all', 'N/A']},
      {'code': 'CC3', 'text': 'If aware of CC (answered codes 1-3 in CC1), how much did the CC help you in your transaction?', 'type': 'multiple_choice', 'options': ['Helped very much', 'Somewhat helped', 'Did not help', 'N/A']},
      {'code': 'SQD0', 'text': 'I am satisfied with the service that I availed', 'type': 'satisfaction'},
      {'code': 'SQD1', 'text': 'I spent a reasonable amount of time for my transaction', 'type': 'rating'},
      {'code': 'SQD2', 'text': 'The office followed the transaction\'s requirements and steps based on the information provided', 'type': 'rating'},
      {'code': 'SQD3', 'text': 'The steps (including payment) I needed to do for my transaction were easy and simple', 'type': 'rating'},
      {'code': 'SQD4', 'text': 'I easily found information about my transaction from the office or its website', 'type': 'rating'},
      {'code': 'SQD5', 'text': 'I paid a reasonable amount of fees for my transaction', 'type': 'rating'},
      {'code': 'SQD6', 'text': 'I feel the office was fair to everyone, or "walang palakasan"', 'type': 'rating'},
      {'code': 'SQD7', 'text': 'I was treated courteously by the staff, and (if asked for help) the staff was helpful', 'type': 'rating'},
      {'code': 'SQD8', 'text': 'I got what I needed from the government office, or (if denied) denial of request was sufficiently explained to me', 'type': 'rating'},
    ];
  }

  static Map<String, dynamic>? getDefaultSurveyData() {
    return {
      'department_id': null, // Will use first available department
      'title': 'ARTA Customer Satisfaction Survey'
    };
  }
}