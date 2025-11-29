import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'survey_form.dart';

class DynamicSurveyPage extends StatelessWidget {
  final Map<String, dynamic>? surveyData;
  final List<Map<String, dynamic>> questions;

  const DynamicSurveyPage({
    super.key,
    required this.surveyData,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  Container(color: Colors.grey.shade800),
            ),
          ),
          // Dark overlay for contrast
          Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.55))),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                          vertical: size.height * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Header - Anti Red Tape Authority
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Anti',
                                  style: GoogleFonts.racingSansOne(
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 34,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: 'Red Tape',
                                  style: GoogleFonts.racingSansOne(
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 34,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(-2, -2),
                                          color: Color(0xFFE53935),
                                        ),
                                        Shadow(
                                          offset: Offset(2, -2),
                                          color: Color(0xFFE53935),
                                        ),
                                        Shadow(
                                          offset: Offset(2, 2),
                                          color: Color(0xFFE53935),
                                        ),
                                        Shadow(
                                          offset: Offset(-2, 2),
                                          color: Color(0xFFE53935),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: ' Authority',
                                  style: GoogleFonts.racingSansOne(
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 34,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Survey title if from QR code
                          if (surveyData != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                surveyData!['title'] ?? 'Custom Survey',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Description
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'This Client Satisfaction Measurement (CSM) tracks the customer experience of government offices. Your feedback on your recently concluded transaction will help this office provide a better service.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Agreement Card
                          Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      size.width < 420 ? size.width - 36 : 360),
                              child: Material(
                                borderRadius: BorderRadius.circular(12),
                                elevation: 12,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Header with logo
                                    Image.asset('assets/logo_heading.png',
                                        height: size.height * 0.05,
                                        fit: BoxFit.contain,
                                        errorBuilder: (ctx, err, st) =>
                                            SizedBox(
                                                height: size.height * 0.05)),
                                    // White body
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 18),
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(12),
                                              bottomRight:
                                                  Radius.circular(12))),
                                      child: Column(
                                        children: [
                                          Text('SURVEY',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black87,
                                                  height: 1.3)),
                                          const SizedBox(height: 16),
                                          
                                          // Show survey info
                                          if (surveyData != null) ...[
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.blue.shade200),
                                              ),
                                              child: Column(
                                                children: [
                                                  Icon(Icons.qr_code, color: Colors.blue.shade600, size: 32),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'QR Code Survey Loaded',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.blue.shade800,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${questions.length} questions',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.blue.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ] else ...[
                                            Container(
                                              height: size.height * 0.15,
                                              decoration: BoxDecoration(
                                                  color: const Color(0xFFF5F5F5),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade300)),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.assignment, 
                                                      color: Colors.grey.shade600, 
                                                      size: 32),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Default ARTA Survey',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.grey.shade700,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${questions.length} questions',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                          
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 44,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            SurveyFormPage(
                                                              customQuestions: questions,
                                                              surveyData: surveyData,
                                                            )));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF8B7FE8),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                  elevation: 2),
                                              child: Text('Start Survey',
                                                  style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}