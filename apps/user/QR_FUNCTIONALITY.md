# QR Code Survey Functionality

## Overview
The user app now supports dynamic survey loading through QR code scanning. Users can either scan a QR code to load custom survey questions or use the default ARTA survey questions.

## How It Works

### 1. QR Code Scanning
- Users can tap "Scan QR" button on the landing page
- Camera opens to scan QR codes
- QR codes should contain URLs in format: `https://yourapp.com/survey/{surveyId}`
- If QR scan fails or is skipped, default questions are used

### 2. Dynamic Question Loading
- Scanned QR codes fetch survey data from admin's Supabase database
- Custom questions and options are loaded dynamically
- If no custom survey is found, falls back to default ARTA questions

### 3. Question Types Supported
- **Multiple Choice**: Radio button selection with custom options
- **Rating**: 5-point scale (Strongly Disagree to Strongly Agree)
- **Satisfaction**: Same as rating but with emoji feedback

### 4. Default Questions (Fallback)
When no QR code is scanned or survey data can't be loaded:
- CC1: Awareness of Citizen's Charter
- CC2: CC visibility assessment  
- CC3: CC helpfulness rating
- SQD0-SQD8: Service quality dimensions

## Technical Implementation

### Files Added/Modified:
1. **qr_scanner_page.dart** - QR code scanning interface
2. **dynamic_survey_page.dart** - Landing page for QR-loaded surveys
3. **dynamic_cc_page.dart** - Dynamic question navigation
4. **services/qr_service.dart** - QR data fetching and default questions
5. **main.dart** - Route handling for survey URLs
6. **landing_page.dart** - Added QR scanner button
7. **survey_form.dart** - Support for custom questions

### Dependencies Added:
- `qr_code_scanner: ^1.0.1` - QR code scanning
- `http: ^1.1.0` - API requests for survey data

## Usage Flow

1. **Normal Survey**: User taps "Start Survey" → Uses default questions
2. **QR Survey**: User taps "Scan QR" → Scans code → Loads custom questions
3. **URL Direct**: App opened with survey URL → Loads custom questions directly

## Admin Integration
- Admin creates surveys in admin app
- QR codes generated contain survey template IDs
- User app fetches survey data using the same Supabase instance
- Responses are saved with survey metadata for tracking

## Fallback Behavior
- Invalid QR codes → Default questions
- Network errors → Default questions  
- Missing survey data → Default questions
- Camera permission denied → Option to skip to default questions

This ensures the app always works even if QR scanning fails or custom surveys aren't available.