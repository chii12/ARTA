import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/qr_service.dart';
import 'dynamic_survey_page.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status == PermissionStatus.granted;
    });
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isProcessing && capture.barcodes.isNotEmpty) {
      final barcode = capture.barcodes.first;
      if (barcode.rawValue != null) {
        _processQRCode(barcode.rawValue!);
      }
    }
  }

  void _showManualUrlDialog() {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Survey URL', style: GoogleFonts.poppins()),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            hintText: 'https://yourapp.com/survey/123',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (urlController.text.isNotEmpty) {
                _processQRCode(urlController.text);
              }
            },
            child: const Text('Open Survey'),
          ),
        ],
      ),
    );
  }

  Future<void> _processQRCode(String qrData) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    
    try {
      // Check if it's a survey URL
      if (qrData.contains('/survey/')) {
        final surveyData = await QRService.fetchSurveyFromQR(qrData);
        final finalSurveyData = surveyData ?? QRService.getDefaultSurveyData();
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => DynamicSurveyPage(
                surveyData: finalSurveyData,
                questions: surveyData != null 
                  ? List<Map<String, dynamic>>.from(surveyData['template']['questions'])
                  : QRService.getDefaultQuestions(),
              ),
            ),
          );
        }
      } else {
        // Invalid QR code, use default questions
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => DynamicSurveyPage(
                surveyData: QRService.getDefaultSurveyData(),
                questions: QRService.getDefaultQuestions(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Error occurred, use default questions
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => DynamicSurveyPage(
              surveyData: QRService.getDefaultSurveyData(),
              questions: QRService.getDefaultQuestions(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_hasPermission)
            MobileScanner(
              controller: controller,
              onDetect: _onDetect,
            )
          else
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt, size: 64, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      'Camera Permission Required',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please allow camera access to scan QR codes',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _checkPermission,
                      child: const Text('Grant Permission'),
                    ),
                  ],
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.black.withOpacity(0.7),
                  child: Column(
                    children: [
                      Text(
                        'Scan QR Code',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Point your camera at the QR code to start the survey',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.black.withOpacity(0.7),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => DynamicSurveyPage(
                                surveyData: QRService.getDefaultSurveyData(),
                                questions: QRService.getDefaultQuestions(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B7FE8),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: Text(
                          'Skip QR Code',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _showManualUrlDialog,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: Text(
                          'Enter Survey URL',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Back',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}