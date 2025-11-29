import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/survey_service.dart';

class SQDDesktop extends StatefulWidget {
  final Map<String, dynamic> formData;
  const SQDDesktop({super.key, required this.formData});

  @override
  State<SQDDesktop> createState() => _SQDDesktopState();
}

class _SQDDesktopState extends State<SQDDesktop> {
  final _formKey = GlobalKey<FormState>();
  final _suggestionsCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  
  String? _sqd0;
  String? _sqd1;
  String? _sqd2;
  String? _sqd3;
  String? _sqd4;
  String? _sqd5;
  String? _sqd6;
  String? _sqd7;
  String? _sqd8;

  @override
  void initState() {
    super.initState();
    _sqd0 = widget.formData['sqd0'] as String?;
    _sqd1 = widget.formData['sqd1'] as String?;
    _sqd2 = widget.formData['sqd2'] as String?;
    _sqd3 = widget.formData['sqd3'] as String?;
    _sqd4 = widget.formData['sqd4'] as String?;
    _sqd5 = widget.formData['sqd5'] as String?;
    _sqd6 = widget.formData['sqd6'] as String?;
    _sqd7 = widget.formData['sqd7'] as String?;
    _sqd8 = widget.formData['sqd8'] as String?;
    _suggestionsCtrl.text = widget.formData['suggestions'] as String? ?? '';
    _emailCtrl.text = widget.formData['email'] as String? ?? '';
  }

  @override
  void dispose() {
    _suggestionsCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validate that all CC and SQD questions are answered
    if (widget.formData['cc1'] == null || widget.formData['cc2'] == null || 
        widget.formData['cc3'] == null || _sqd0 == null || _sqd1 == null || 
        _sqd2 == null || _sqd3 == null || _sqd4 == null || _sqd5 == null || 
        _sqd6 == null || _sqd7 == null || _sqd8 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please answer all questions before submitting.',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Create structured survey response
    final surveyData = SurveyService.createSurveyResponse(
      name: widget.formData['name'] as String? ?? '',
      clientType: widget.formData['clientType'] as String? ?? '',
      sex: widget.formData['sex'] as String? ?? '',
      date: widget.formData['date'] as String? ?? '',
      age: widget.formData['age'] as String? ?? '',
      region: widget.formData['region'] as String? ?? '',
      service: widget.formData['service'] as String? ?? '',
      cc1: widget.formData['cc1'] as String?,
      cc2: widget.formData['cc2'] as String?,
      cc3: widget.formData['cc3'] as String?,
      sqd0: _sqd0,
      sqd1: _sqd1,
      sqd2: _sqd2,
      sqd3: _sqd3,
      sqd4: _sqd4,
      sqd5: _sqd5,
      sqd6: _sqd6,
      sqd7: _sqd7,
      sqd8: _sqd8,
      suggestions: _suggestionsCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
    );

    // Submit to backend (currently saves locally)
    final success = await SurveyService.submitSurveyToAPI(surveyData);

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to submit survey. Please try again.',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show thank you popup
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            Text(
              'Thank You!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: Text(
          'Your response has been successfully submitted.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).popUntil((route) => route.isFirst); // Go to landing
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    // Fallback for narrow screens
    if (size.width <= 900) {
      return _buildMobileLayout();
    }
    
    return _buildDesktopLayout();
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Stack(
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
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),
          
          // Content - Fills screen completely
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Logo at top
                          Image.asset(
                            'assets/logo_heading.png',
                            height: 40,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const SizedBox(height: 40),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Form content
                          Expanded(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Instructions
                                  Text(
                                    'For SQD 0-8. Please select the best that corresponds to your answer.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                      height: 1.2,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 6),
                                  
                                  // All SQD questions in expanded area
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // SQD0
                                        _buildSQDQuestion(
                                          'SQD0',
                                          'I am satisfied with the service that availed.',
                                          _sqd0,
                                          (v) => setState(() => _sqd0 = v),
                                        ),
                                        
                                        // SQD1
                                        _buildSQDQuestion(
                                          'SQD1',
                                          'I spent a reasonable amount of time for my transaction.',
                                          _sqd1,
                                          (v) => setState(() => _sqd1 = v),
                                        ),
                                        
                                        // SQD2
                                        _buildSQDQuestion(
                                          'SQD2',
                                          'The office followed the transaction\'s requirements and steps based on the information provided.',
                                          _sqd2,
                                          (v) => setState(() => _sqd2 = v),
                                        ),
                                        
                                        // SQD3
                                        _buildSQDQuestion(
                                          'SQD3',
                                          'The steps (including payment) I needed to do for my transaction were easy and simple.',
                                          _sqd3,
                                          (v) => setState(() => _sqd3 = v),
                                        ),
                                        
                                        // SQD4
                                        _buildSQDQuestion(
                                          'SQD4',
                                          'I easily found information about my transaction from the office or its website.',
                                          _sqd4,
                                          (v) => setState(() => _sqd4 = v),
                                        ),
                                        
                                        // SQD5
                                        _buildSQDQuestion(
                                          'SQD5',
                                          'I paid a reasonable amount of fees for my transaction. (If service was free, mark "N/A" column)',
                                          _sqd5,
                                          (v) => setState(() => _sqd5 = v),
                                        ),
                                        
                                        // SQD6
                                        _buildSQDQuestion(
                                          'SQD6',
                                          'I feel the office was fair to everyone, or "walang palakasan", during my transaction.',
                                          _sqd6,
                                          (v) => setState(() => _sqd6 = v),
                                        ),
                                        
                                        // SQD7
                                        _buildSQDQuestion(
                                          'SQD7',
                                          'I was treated courteously by the staff, and (if asked for help) the staff was helpful.',
                                          _sqd7,
                                          (v) => setState(() => _sqd7 = v),
                                        ),
                                        
                                        // SQD8
                                        _buildSQDQuestion(
                                          'SQD8',
                                          'I got what I needed from the government office, or (if denied) denial of request was sufficiently explained to me.',
                                          _sqd8,
                                          (v) => setState(() => _sqd8 = v),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // Bottom section - always visible
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Suggestions
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Suggestions on how we can further improve our services (optional):',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            SizedBox(
                                              height: 60,
                                              child: TextFormField(
                                                controller: _suggestionsCtrl,
                                                maxLines: 3,
                                                style: GoogleFonts.poppins(fontSize: 10),
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.grey.shade50,
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(4),
                                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(4),
                                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                                  ),
                                                  contentPadding: const EdgeInsets.all(8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      const SizedBox(width: 12),
                                      
                                      // Email and Submit
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              'email address (optional):',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            SizedBox(
                                              height: 35,
                                              child: TextFormField(
                                                controller: _emailCtrl,
                                                keyboardType: TextInputType.emailAddress,
                                                style: GoogleFonts.poppins(fontSize: 10),
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.grey.shade50,
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(4),
                                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(4),
                                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 8,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TextButton.icon(
                                                    onPressed: () => Navigator.of(context).pop(),
                                                    icon: const Icon(Icons.arrow_back, size: 14),
                                                    label: Text(
                                                      'Previous',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: const Color(0xFF6366F1),
                                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: _submit,
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.red,
                                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'SUBMIT',
                                                      style: GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 13,
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
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/background.jpeg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) =>
                Container(color: const Color(0xFF2C2C2C)),
          ),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.4)),
        ),
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Please use a wider screen for the survey',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSQDQuestion(
    String badge,
    String question,
    String? selection,
    ValueChanged<String?> onChanged,
  ) {
    final options = [
      {'bw': 'assets/emoticons/STRONGLY DISAGREE-BW.png', 'color': 'assets/emoticons/STRONGLY DISAGREE.png', 'value': 'STRONGLY DISAGREE'},
      {'bw': 'assets/emoticons/DISAGREE-BW.png', 'color': 'assets/emoticons/DISAGREE.png', 'value': 'DISAGREE'},
      {'bw': 'assets/emoticons/NEITHER AGREE NOR DISAGREE-BW.png', 'color': 'assets/emoticons/NEITHER AGREE NOR DISAGREE.png', 'value': 'NEITHER AGREE NOR DISAGREE'},
      {'bw': 'assets/emoticons/AGREE-BW.png', 'color': 'assets/emoticons/AGREE.png', 'value': 'AGREE'},
      {'bw': 'assets/emoticons/STRONGLY AGREE-BW.png', 'color': 'assets/emoticons/STRONGLY AGREE.png', 'value': 'STRONGLY AGREE'},
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Badge
        Container(
          width: 50,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            badge,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Question
        Expanded(
          flex: 3,
          child: Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Emoji options in a row
        ...options.map((option) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: InkWell(
            onTap: () => onChanged(option['value'] as String),
            child: Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selection == option['value']
                    ? Colors.orange.shade100
                    : Colors.transparent,
                border: Border.all(
                  color: selection == option['value']
                      ? Colors.orange
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Image.asset(
                selection == option['value']
                    ? option['color'] as String
                    : option['bw'] as String,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.sentiment_neutral, size: 40),
              ),
            ),
          ),
        )),
        
        // Not Applicable option
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: InkWell(
            onTap: () => onChanged('NOT APPLICABLE'),
            child: Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selection == 'NOT APPLICABLE'
                    ? Colors.red.shade100
                    : Colors.transparent,
                border: Border.all(
                  color: selection == 'NOT APPLICABLE'
                      ? Colors.red
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Image.asset(
                selection == 'NOT APPLICABLE'
                    ? 'assets/emoticons/X.png'
                    : 'assets/emoticons/X-BW.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.close, size: 40),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
