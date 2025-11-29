# ARTA User Survey Application - Backend Integration Guide

## 📋 Overview

This is a complete Flutter frontend application for the ARTA (Anti Red Tape Authority) User Survey. The application is **fully functional** and **ready for backend integration**.

## ✅ Current Features

### Mobile Version
- Landing page with ARTA information
- Survey form (Name, Client Type, Sex, Date, Age, Service, Region)
- CC Questions (3 questions about Citizen's Charter awareness)
- SQD Questions (9 questions about service quality)
- Suggestions and feedback section
- Response submission with local storage

### Desktop Version (Width > 900px)
- Desktop-optimized landing page
- Combined Survey + CC Questions page (split view)
- Combined SQD Questions page (all in one view with emoticons)
- Responsive layout with proper validation
- Previous/Next navigation
- Thank you popup on submission

## 🗂️ Data Structure

### Survey Response Format

The application collects data in the following structured format:

```json
{
  "timestamp": "2025-11-16T10:30:00.000Z",
  "personalInfo": {
    "name": "Juan Dela Cruz",
    "clientType": "Citizen|Business|Government",
    "sex": "Male|Female",
    "date": "2025-11-16",
    "age": "35",
    "region": "NCR",
    "serviceAvailed": "Business Permit"
  },
  "ccQuestions": {
    "cc1": "I know what a CC is and I saw this office's CC.",
    "cc2": "Easy to see",
    "cc3": "Helped very much"
  },
  "sqdQuestions": {
    "sqd0": "STRONGLY AGREE",
    "sqd1": "AGREE",
    "sqd2": "NEITHER AGREE NOR DISAGREE",
    "sqd3": "AGREE",
    "sqd4": "STRONGLY AGREE",
    "sqd5": "AGREE",
    "sqd6": "STRONGLY AGREE",
    "sqd7": "AGREE",
    "sqd8": "STRONGLY AGREE"
  },
  "feedback": {
    "suggestions": "Optional suggestions text",
    "email": "optional@email.com"
  }
}
```

## 🔧 Backend Integration Steps

### 1. Service File Location
The main service file is located at: `lib/services/survey_service.dart`

### 2. Methods to Implement

#### A. Submit Survey to API
Replace the TODO in `submitSurveyToAPI()` method:

```dart
static Future<bool> submitSurveyToAPI(Map<String, dynamic> data) async {
  try {
    final response = await http.post(
      Uri.parse('YOUR_API_ENDPOINT/api/surveys'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer YOUR_TOKEN', // if needed
      },
      body: jsonEncode(data),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print('API Error: ${response.statusCode} - ${response.body}');
      return false;
    }
  } catch (e) {
    print('Network Error: $e');
    return false;
  }
}
```

#### B. Sync Pending Surveys
Implement offline-to-online sync:

```dart
static Future<bool> syncPendingSurveys() async {
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
}
```

#### C. Check Internet Connectivity
Add connectivity check (requires `connectivity_plus` package):

```dart
static Future<bool> hasInternetConnection() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}
```

### 3. Add Required Packages

Add to `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.2.0  # For API calls
  connectivity_plus: ^6.0.3  # For internet connectivity check
```

Then run: `flutter pub get`

### 4. API Endpoints Needed

Your backend should provide these endpoints:

```
POST /api/surveys
- Create a new survey response
- Request Body: Survey response JSON (see data structure above)
- Response: 201 Created with survey ID

GET /api/surveys
- Retrieve all surveys (admin only)
- Response: Array of survey responses

GET /api/surveys/stats
- Get survey statistics
- Response: Aggregated data and charts
```

## 📊 Current Data Storage

Currently, data is stored **locally** using `SharedPreferences` under the key `arta_surveys`.

### Access Local Data

```dart
// Get all stored surveys
final surveys = await SurveyService.getLocalSurveys();

// Get count of pending surveys
final count = await SurveyService.getPendingSurveyCount();

// Clear all local data (after successful sync)
await SurveyService.clearLocalSurveys();
```

## 🔒 Security Considerations

When integrating with backend:

1. **Use HTTPS** for all API calls
2. **Implement authentication** if needed (JWT tokens)
3. **Validate data** on both frontend and backend
4. **Sanitize user inputs** to prevent SQL injection
5. **Rate limit** API endpoints to prevent abuse
6. **Encrypt sensitive data** in transit and at rest

## 📱 Testing Checklist

Before deploying with backend:

- [ ] Test API connectivity
- [ ] Test offline mode (saves locally)
- [ ] Test online mode (submits to API)
- [ ] Test sync functionality
- [ ] Test error handling (network failures)
- [ ] Test with large datasets
- [ ] Test on different screen sizes
- [ ] Test validation rules
- [ ] Test form data persistence

## 🚀 Deployment

### For Mobile (Android/iOS)
```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

### For Web
```bash
flutter build web --release
```

### For Desktop
```bash
flutter build windows --release  # Windows
flutter build macos --release   # macOS
flutter build linux --release   # Linux
```

## 📞 Support

For questions about backend integration, refer to:
- `lib/services/survey_service.dart` - Main service file with TODO comments
- Survey data structure documented above
- Flutter HTTP documentation: https://pub.dev/packages/http

## ✨ Features Ready for Backend

✅ Complete data validation
✅ Structured data format
✅ Error handling
✅ Offline storage
✅ Ready for sync mechanism
✅ Timestamp tracking
✅ Optional fields handling
✅ Mobile and desktop responsive
✅ User-friendly error messages
✅ Success confirmation dialogs

---

**Application Status: 100% Frontend Complete - Ready for Backend Integration**
