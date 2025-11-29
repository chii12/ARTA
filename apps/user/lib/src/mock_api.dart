import 'dart:async';

/// Minimal mock API used to satisfy references after the lib/ cleanup.
class MockApi {
  MockApi._();
  static final instance = MockApi._();

  final _profileController = StreamController<Map<String, String>>.broadcast();
  final _responsesController =
      StreamController<List<Map<String, String>>>.broadcast();

  Stream<Map<String, String>> get profileStream => _profileController.stream;
  Stream<List<Map<String, String>>> get responsesStream =>
      _responsesController.stream;

  Future<Map<String, String>> fetchAdminProfile() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return {'name': 'Demo Admin', 'role': 'admin', 'email': 'demo@gov.ph'};
  }

  Future<List<Map<String, String>>> fetchResponses() async {
    await Future.delayed(const Duration(milliseconds: 50));
    final list = <Map<String, String>>[];
    try {
      _responsesController.add(list);
    } catch (_) {}
    return list;
  }

  Future<List<Map<String, String>>> fetchSurveys() async {
    return fetchResponses();
  }

  Future<List<Map<String, String>>> fetchUsers() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return <Map<String, String>>[];
  }

  Future<bool> saveProfile(Map<String, String> profile) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      _profileController.add(Map<String, String>.from(profile));
    } catch (_) {}
    return true;
  }
}
