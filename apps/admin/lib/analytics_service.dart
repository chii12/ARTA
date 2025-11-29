import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsService {
  static final _client = Supabase.instance.client;

  // Get department analytics for logged-in admin
  static Future<Map<String, dynamic>> getDepartmentAnalytics(String userDepartmentId) async {
    try {
      // Get total surveys for department
      final surveysResponse = await _client
          .from('surveys')
          .select('survey_id')
          .eq('department_id', userDepartmentId);

      final totalSurveys = surveysResponse.length;

      // Get survey IDs for this department
      final surveyIds = surveysResponse.map((s) => s['survey_id']).toList();

      if (surveyIds.isEmpty) {
        return {
          'totalSurveys': 0,
          'totalResponses': 0,
          'averageRating': 0.0,
          'satisfactionRate': 0.0,
        };
      }

      // Get total responses for department surveys only
      final responsesResponse = await _client
          .from('responses')
          .select('response_id')
          .inFilter('survey_id', surveyIds);

      final totalResponses = responsesResponse.length;

      // Get response IDs for department surveys
      final responseIds = responsesResponse.map((r) => r['response_id']).toList();

      if (responseIds.isEmpty) {
        return {
          'totalSurveys': totalSurveys,
          'totalResponses': 0,
          'averageRating': 0.0,
          'satisfactionRate': 0.0,
        };
      }

      // Get average ratings for department responses only
      final ratingsResponse = await _client
          .from('response_answers')
          .select('rating_value')
          .inFilter('response_id', responseIds)
          .not('rating_value', 'is', null);

      double averageRating = 0.0;
      if (ratingsResponse.isNotEmpty) {
        final ratings = ratingsResponse.map((r) => r['rating_value'] as int).toList();
        averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
      }

      return {
        'totalSurveys': totalSurveys,
        'totalResponses': totalResponses,
        'averageRating': averageRating,
        'satisfactionRate': averageRating >= 4 ? (averageRating / 5 * 100) : 0,
      };
    } catch (e) {
      print('Error getting department analytics: $e');
      return {
        'totalSurveys': 0,
        'totalResponses': 0,
        'averageRating': 0.0,
        'satisfactionRate': 0.0,
      };
    }
  }

  // Get recent responses for department
  static Future<List<Map<String, dynamic>>> getRecentResponses(String userDepartmentId, {int limit = 10}) async {
    try {
      // First get survey IDs for this department
      final surveysResponse = await _client
          .from('surveys')
          .select('survey_id')
          .eq('department_id', userDepartmentId);

      final surveyIds = surveysResponse.map((s) => s['survey_id']).toList();

      if (surveyIds.isEmpty) {
        return [];
      }

      // Get responses only for department surveys
      final response = await _client
          .from('responses')
          .select('''
            response_id,
            date_submitted,
            survey_id,
            respondents(name, client_type),
            services(service_name)
          ''')
          .inFilter('survey_id', surveyIds)
          .order('date_submitted', ascending: false)
          .limit(limit);

      // Get survey titles separately
      final surveyTitles = Map.fromEntries(
        surveysResponse.map((s) => MapEntry(s['survey_id'], s['title'] ?? 'Unknown Survey'))
      );

      // Add survey titles to responses
      return response.map((r) => {
        ...r,
        'survey_title': surveyTitles[r['survey_id']] ?? 'Unknown Survey'
      }).toList();
    } catch (e) {
      print('Error getting recent responses: $e');
      return [];
    }
  }

  // Get survey performance for department
  static Future<List<Map<String, dynamic>>> getSurveyPerformance(String userDepartmentId) async {
    try {
      // Get surveys for this department only
      final surveysResponse = await _client
          .from('surveys')
          .select('survey_id, title, survey_date')
          .eq('department_id', userDepartmentId)
          .order('survey_date', ascending: false);

      List<Map<String, dynamic>> result = [];

      for (var survey in surveysResponse) {
        final surveyId = survey['survey_id'];
        
        // Get responses for this specific survey
        final responsesResponse = await _client
            .from('responses')
            .select('response_id')
            .eq('survey_id', surveyId);

        final totalResponses = responsesResponse.length;
        final responseIds = responsesResponse.map((r) => r['response_id']).toList();

        double avgRating = 0.0;
        if (responseIds.isNotEmpty) {
          // Get ratings for this survey's responses
          final ratingsResponse = await _client
              .from('response_answers')
              .select('rating_value')
              .inFilter('response_id', responseIds)
              .not('rating_value', 'is', null);

          if (ratingsResponse.isNotEmpty) {
            final ratings = ratingsResponse.map((r) => r['rating_value'] as int).toList();
            avgRating = ratings.reduce((a, b) => a + b) / ratings.length;
          }
        }

        result.add({
          'survey_id': survey['survey_id'],
          'title': survey['title'],
          'survey_date': survey['survey_date'],
          'total_responses': totalResponses,
          'average_rating': avgRating,
        });
      }

      return result;
    } catch (e) {
      print('Error getting survey performance: $e');
      return [];
    }
  }

  // Get service analytics for department
  static Future<List<Map<String, dynamic>>> getServiceAnalytics(String userDepartmentId) async {
    try {
      // Get services for this department only
      final servicesResponse = await _client
          .from('services')
          .select('service_id, service_name')
          .eq('department_id', userDepartmentId);

      List<Map<String, dynamic>> result = [];

      for (var service in servicesResponse) {
        final serviceId = service['service_id'];
        
        // Get responses for this specific service
        final responsesResponse = await _client
            .from('responses')
            .select('response_id')
            .eq('service_availed_id', serviceId);

        final totalResponses = responsesResponse.length;
        final responseIds = responsesResponse.map((r) => r['response_id']).toList();

        double avgRating = 0.0;
        if (responseIds.isNotEmpty) {
          // Get ratings for this service's responses
          final ratingsResponse = await _client
              .from('response_answers')
              .select('rating_value')
              .inFilter('response_id', responseIds)
              .not('rating_value', 'is', null);

          if (ratingsResponse.isNotEmpty) {
            final ratings = ratingsResponse.map((r) => r['rating_value'] as int).toList();
            avgRating = ratings.reduce((a, b) => a + b) / ratings.length;
          }
        }

        result.add({
          'service_id': service['service_id'],
          'service_name': service['service_name'],
          'total_responses': totalResponses,
          'average_rating': avgRating,
        });
      }

      return result;
    } catch (e) {
      print('Error getting service analytics: $e');
      return [];
    }
  }
}