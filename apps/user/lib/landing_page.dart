import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'survey_form.dart';
import 'saved_surveys_page.dart';
import 'services/survey_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _isExpanded = false;
  int _surveyCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSurveyCount();
  }

  Future<void> _loadSurveyCount() async {
    final count = await SurveyService.getPendingSurveyCount();
    setState(() => _surveyCount = count);
  }

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

                          // Lorem ipsum Section - Plain text on dark background
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: AnimatedCrossFade(
                              firstChild: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'The Anti-Red Tape Authority (ARTA) is a government agency in the Philippines established to streamline public service processes and eliminate bureaucratic inefficiencies. Its main goal is to ensure faster, more transparent, and citizen-friendly government services by implementing the provisions of the Anti-Red Tape Act (RA 11032). ARTA monitors compliance, addresses complaints, and promotes reforms to reduce delays and improve government accountability.',
                                    ),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _isExpanded = true),
                                        child: Text(
                                          'See More...',
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF8B7FE8),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.underline,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              secondChild: Column(
                                children: [
                                  // Keep first paragraph visible
                                  Text(
                                    'The Anti-Red Tape Authority (ARTA) is a government agency in the Philippines established to streamline public service processes and eliminate bureaucratic inefficiencies. Its main goal is to ensure faster, more transparent, and citizen-friendly government services by implementing the provisions of the Anti-Red Tape Act (RA 11032). ARTA monitors compliance, addresses complaints, and promotes reforms to reduce delays and improve government accountability.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Purpose heading inside expanded section
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Purpose of Anti ',
                                          style: GoogleFonts.racingSansOne(
                                            textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Red Tape',
                                          style: GoogleFonts.racingSansOne(
                                            textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.0,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(-1.5, -1.5),
                                                  color: Color(0xFFE53935),
                                                ),
                                                Shadow(
                                                  offset: Offset(1.5, -1.5),
                                                  color: Color(0xFFE53935),
                                                ),
                                                Shadow(
                                                  offset: Offset(1.5, 1.5),
                                                  color: Color(0xFFE53935),
                                                ),
                                                Shadow(
                                                  offset: Offset(-1.5, 1.5),
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
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'The purpose of the Anti-Red Tape Authority (ARTA) is to streamline government processes, reduce bureaucratic delays, and ensure efficient, transparent, and citizen-friendly public services. It monitors compliance with the Anti-Red Tape Act (RA 11032), addresses complaints, and promotes reforms to improve accountability and service delivery across government agencies.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () => setState(() => _isExpanded = false),
                                    child: Text(
                                      'See Less',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF8B7FE8),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              crossFadeState: _isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 300),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Agreement Card with a darker header and white body (matches screenshot)
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
                                          Text('AGREEMENT',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black87,
                                                  height: 1.3)),
                                          const SizedBox(height: 16),
                                          Container(
                                            height: size.height * 0.25,
                                            decoration: BoxDecoration(
                                                color: const Color(0xFFF5F5F5),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300)),
                                            child: const SingleChildScrollView(
                                              padding: EdgeInsets.all(12.0),
                                              child: Text('',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 13)),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: SizedBox(
                                                  height: 44,
                                                  child: OutlinedButton.icon(
                                                    onPressed: () {
                                                      Navigator.of(context).pushNamed('/qr');
                                                    },
                                                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                                                    label: Text('Scan QR',
                                                        style: GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 14)),
                                                    style: OutlinedButton.styleFrom(
                                                        foregroundColor: const Color(0xFF8B7FE8),
                                                        side: const BorderSide(color: Color(0xFF8B7FE8)),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(8))),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: SizedBox(
                                                  height: 44,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  const SurveyFormPage()));
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
                                                            fontSize: 14)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (_surveyCount > 0) ...[
                                            const SizedBox(height: 8),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => const SavedSurveysPage(),
                                                ),
                                              ),
                                              child: Text(
                                                'View $_surveyCount Saved Response${_surveyCount == 1 ? '' : 's'}',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ]
                                        
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
