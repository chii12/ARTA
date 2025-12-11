import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'survey_form.dart';

class LandingPageDesktop extends StatefulWidget {
  const LandingPageDesktop({super.key});

  @override
  State<LandingPageDesktop> createState() => _LandingPageDesktopState();
}

class _LandingPageDesktopState extends State<LandingPageDesktop> {
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    
    return Scaffold(
      body: isWideScreen 
        ? _buildDesktopLayout(context, size)
        : _buildMobileLayout(context, size),
    );
  }

  // Desktop layout - split view
  Widget _buildDesktopLayout(BuildContext context, Size size) {
    return Row(
      children: [
        // Left side - White panel with Agreement
        Container(
          width: size.width * 0.38,
          constraints: const BoxConstraints(minWidth: 300, maxWidth: 500),
          color: Colors.white,
          child: Column(
            children: [
              // Header with logo
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/city_logo.png',
                      height: 48,
                      width: 48,
                      errorBuilder: (ctx, error, stack) => 
                        const Icon(Icons.location_city, size: 48, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'CITY GOVERNMENT OF VALENZUELA',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'HERE TO SERVE YOU BETTER!',
                            style: GoogleFonts.poppins(
                              fontSize: 7,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Agreement section
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'TERMS AND CONDITIONS',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'By continuing to access and accomplish this Customer Satisfaction Survey, you hereby acknowledge and agree to the following terms and conditions:',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '1. Purpose of Data Collection',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'I understand that the information I provide shall be utilized exclusively for the evaluation, monitoring, and continuous improvement of the services rendered by the City Government of Valenzuela. All collected data will support the City\'s efforts to enhance service quality and uphold ARTA-compliant standards.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '2. Data Privacy and Confidentiality',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'I acknowledge that the City Government of Valenzuela is fully committed to protecting my personal information in compliance with the Data Privacy Act of 2012 and its implementing rules and regulations. All personal data collected through this survey will be treated with strict confidentiality and will not be disclosed to unauthorized individuals or entities.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '3. Rights of the Data Subject',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'I understand that, as a data subject, I am entitled to the following rights under the Data Privacy Act:\n• The right to be informed regarding the collection, processing, and purpose of my personal data;\n• The right to access my personal information and request corrections for any inaccuracies;\n• The right to object to the processing of my personal data, subject to applicable laws and regulations;\n• The right to lodge a complaint with the National Privacy Commission for any concerns relating to the handling of my personal data.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '4. Voluntary Participation',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'I acknowledge that my participation in this survey is entirely voluntary and that I may discontinue or decline to proceed at any time without penalty.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _agreedToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreedToTerms = value ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: Text(
                                'I confirm that I have carefully read, understood, and voluntarily consent to the provisions stated above.',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Survey Buttons
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: _agreedToTerms ? () {
                                  Navigator.of(context).pushNamed('/qr');
                                } : null,
                                icon: const Icon(Icons.qr_code_scanner, size: 20),
                                label: Text(
                                  'Scan QR',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _agreedToTerms ? const Color(0xFF0A84FF) : Colors.grey,
                                  side: BorderSide(color: _agreedToTerms ? const Color(0xFF0A84FF) : Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _agreedToTerms ? () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SurveyFormPage(),
                                    ),
                                  );
                                } : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _agreedToTerms ? const Color(0xFF0A84FF) : Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Take Survey',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Right side - Background with ARTA content
        Expanded(
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.asset(
                  'assets/background.jpeg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) =>
                      Container(color: const Color(0xFF2b3e50)),
                ),
              ),
              
              // Dark overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.65),
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Content
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main heading
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Anti',
                              style: GoogleFonts.racingSansOne(
                                fontSize: 48,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                letterSpacing: 1.5,
                                height: 1.3,
                              ),
                            ),
                            TextSpan(
                              text: 'Red Tape',
                              style: GoogleFonts.racingSansOne(
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1.5,
                                height: 1.3,
                                shadows: [
                                  const Shadow(offset: Offset(-2.5, -2.5), color: Color(0xFFD32F2F)),
                                  const Shadow(offset: Offset(2.5, -2.5), color: Color(0xFFD32F2F)),
                                  const Shadow(offset: Offset(2.5, 2.5), color: Color(0xFFD32F2F)),
                                  const Shadow(offset: Offset(-2.5, 2.5), color: Color(0xFFD32F2F)),
                                ],
                              ),
                            ),
                            TextSpan(
                              text: ' Authority',
                              style: GoogleFonts.racingSansOne(
                                fontSize: 48,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                letterSpacing: 1.5,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // First description
                      Text(
                        'The Anti-Red Tape Authority (ARTA) is a government agency in the Philippines established to streamline public service processes and eliminate bureaucratic inefficiencies. Its main goal is to ensure faster, more transparent, and citizen-friendly government services by implementing the provisions of the Anti-Red Tape Act (RA 11032). ARTA monitors compliance, addresses complaints, and promotes reforms to reduce delays and improve government accountability.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white,
                          height: 1.8,
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Purpose heading
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Purpose of Anti ',
                              style: GoogleFonts.racingSansOne(
                                fontSize: 42,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                letterSpacing: 1.2,
                                height: 1.3,
                              ),
                            ),
                            TextSpan(
                              text: 'Red Tape',
                              style: GoogleFonts.racingSansOne(
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1.2,
                                height: 1.3,
                                shadows: [
                                  const Shadow(offset: Offset(-2, -2), color: Color(0xFFD32F2F)),
                                  const Shadow(offset: Offset(2, -2), color: Color(0xFFD32F2F)),
                                  const Shadow(offset: Offset(2, 2), color: Color(0xFFD32F2F)),
                                  const Shadow(offset: Offset(-2, 2), color: Color(0xFFD32F2F)),
                                ],
                              ),
                            ),
                            TextSpan(
                              text: ' Authority',
                              style: GoogleFonts.racingSansOne(
                                fontSize: 42,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                letterSpacing: 1.2,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Second description
                      Text(
                        'The purpose of the Anti-Red Tape Authority (ARTA) is to streamline government processes, reduce bureaucratic delays, and ensure efficient, transparent, and citizen-friendly public services. It monitors compliance with the Anti-Red Tape Act (RA 11032), addresses complaints, and promotes reforms to improve accountability and service delivery across government agencies.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white,
                          height: 1.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Mobile layout fallback
  Widget _buildMobileLayout(BuildContext context, Size size) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/background.jpeg',
            fit: BoxFit.cover,
            errorBuilder: (ctx, error, stack) =>
                Container(color: Colors.grey.shade800),
          ),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.6)),
        ),
        
        SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.03,
            ),
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Anti',
                        style: GoogleFonts.racingSansOne(
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: 'Red Tape',
                        style: GoogleFonts.racingSansOne(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: [
                            const Shadow(offset: Offset(-2, -2), color: Color(0xFFD32F2F)),
                            const Shadow(offset: Offset(2, -2), color: Color(0xFFD32F2F)),
                            const Shadow(offset: Offset(2, 2), color: Color(0xFFD32F2F)),
                            const Shadow(offset: Offset(-2, 2), color: Color(0xFFD32F2F)),
                          ],
                        ),
                      ),
                      TextSpan(
                        text: ' Authority',
                        style: GoogleFonts.racingSansOne(
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                Text(
                  'Lorem ipsum dolor sit amet consectetur adipiscing elit...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                ),
                const SizedBox(height: 30),
                
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'AGREEMENT',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/qr');
                                },
                                icon: const Icon(Icons.qr_code_scanner, size: 18),
                                label: Text(
                                  'Scan QR',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF0A84FF),
                                  side: const BorderSide(color: Color(0xFF0A84FF)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const SurveyFormPage()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0A84FF),
                                ),
                                child: Text(
                                  'Take Survey',
                                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
