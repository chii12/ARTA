# QR Scanner Fix & Alternative Access

## Issues Fixed

### 1. White Box Camera Issue
**Problem**: QR scanner shows white box without camera access
**Solution**: Added camera permissions to `android/app/src/main/AndroidManifest.xml`

### 2. Alternative Access Methods
Added multiple ways to access surveys:

## Access Methods

### Method 1: In-App QR Scanner (Fixed)
1. Open ARTA User app
2. Tap "Scan QR Code"
3. Allow camera permission when prompted
4. Point camera at QR code

### Method 2: Manual URL Entry
1. Open ARTA User app
2. Tap "Scan QR Code"
3. Tap "Enter Survey URL"
4. Paste survey URL: `https://yourapp.com/survey/123`

### Method 3: Any QR Scanner App
1. Use any QR scanner app (Google Lens, built-in camera, etc.)
2. Scan QR code containing survey URL
3. Tap the link to open in ARTA User app
4. App will automatically load the survey

### Method 4: Direct Browser Link
1. Open survey URL in browser: `https://yourapp.com/survey/123`
2. Browser will prompt to open in ARTA User app
3. Tap "Open" to launch survey

## QR Code Generator
Use `web/qr_generator.html` to create test QR codes:
1. Open the HTML file in browser
2. Enter survey URL
3. Generate QR code
4. Test with any scanner

## URL Formats Supported
- `https://yourapp.com/survey/123`
- `artasurvey://survey/123`
- `/survey/123` (internal routing)

## Testing
1. Generate QR code with the web tool
2. Test with phone's built-in camera app
3. Test with Google Lens
4. Test with in-app scanner (after permissions fix)