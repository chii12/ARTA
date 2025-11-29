import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'survey_form.dart';

class LandingPageDesktop extends StatelessWidget {
  const LandingPageDesktop({super.key});

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
                        'AGREEMENT',
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Empty space for agreement content
                      Container(
                        height: 280,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
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
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/qr');
                                },
                                icon: const Icon(Icons.qr_code_scanner, size: 20),
                                label: Text(
                                  'Scan QR',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF0A84FF),
                                  side: const BorderSide(color: Color(0xFF0A84FF)),
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
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SurveyFormPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0A84FF),
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
                        'Lorem ipsum dolor sit amet consectetur adipiscing elit. Ex sapien vitae pellentesque sem placerat in id. Pretium tellus duis convallis tempus leo eu aenean. Ullamcorper integer facilisis vitae cras. Risus non pellentesque lorem duis viverra sed nec. Eget tincidunt eget pellentesque lectus pede. Libero mollis leo mauris tellus imperdiet lacus. Quis amet libero cras etiam amet bibendum. Vitae maecenas faucibus dis vitae maecenas penatibus non. Mauris congue ornare egestas faucibus elit. Vulputate lorem eu ex vulputate. Felis mauris lacus id consequat non porta sapien elementum. Nullam euismod vel duis massa varius vitae.',
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
                        'Lorem ipsum dolor sit amet consectetur adipiscing elit. Ex sapien vitae pellentesque sem placerat in id. Pretium tellus duis convallis tempus leo eu aenean. Ullamcorper integer facilisis vitae cras. Risus non pellentesque lorem duis viverra sed nec. Eget tincidunt eget pellentesque lectus pede. Libero mollis leo mauris tellus imperdiet lacus. Quis amet libero cras etiam amet bibendum. Vitae maecenas faucibus dis vitae maecenas penatibus non. Mauris congue ornare egestas faucibus elit. Vulputate lorem eu ex vulputate. Felis mauris lacus id consequat non porta sapien elementum. Nullam euismod vel duis massa varius vitae.',
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
