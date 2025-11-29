import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cc_pages.dart';
import 'sqd_desktop.dart';

class SurveyCCDesktop extends StatefulWidget {
  const SurveyCCDesktop({super.key});

  @override
  State<SurveyCCDesktop> createState() => _SurveyCCDesktopState();
}

class _SurveyCCDesktopState extends State<SurveyCCDesktop> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();
  final TextEditingController _ageCtrl = TextEditingController();
  final TextEditingController _regionCtrl = TextEditingController();
  final TextEditingController _serviceCtrl = TextEditingController();

  String? _clientType;
  String? _sex;
  
  // CC selections
  String? _cc1;
  String? _cc2;
  String? _cc3;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dateCtrl.dispose();
    _ageCtrl.dispose();
    _regionCtrl.dispose();
    _serviceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      _dateCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  void _next() {
    final size = MediaQuery.of(context).size;
    final data = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'clientType': _clientType,
      'sex': _sex,
      'date': _dateCtrl.text,
      'age': _ageCtrl.text,
      'region': _regionCtrl.text.trim(),
      'service': _serviceCtrl.text.trim(),
      'cc1': _cc1,
      'cc2': _cc2,
      'cc3': _cc3,
    };
    
    // Use desktop version for wide screens
    if (size.width > 900) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SQDDesktop(formData: data)),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SQD0Page(formData: data)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;

    return Scaffold(
      body: isWideScreen
          ? _buildDesktopLayout(size)
          : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout(Size size) {
    return Row(
      children: [
        // Left Panel - Survey Form (White)
        Container(
          width: size.width * 0.35,
          constraints: const BoxConstraints(minWidth: 300, maxWidth: 450),
          color: Colors.white,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/city_logo.png',
                      height: 40,
                      width: 40,
                      errorBuilder: (context, error, stack) =>
                          const Icon(Icons.location_city, size: 40),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CITY GOVERNMENT OF VALENZUELA',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'HERE TO SERVE YOU BETTER!',
                            style: GoogleFonts.poppins(
                              fontSize: 7,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameCtrl,
                          style: GoogleFonts.poppins(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Optional',
                            filled: true,
                            fillColor: const Color(0xFFE8F0FF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        Text(
                          'Client Type',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildRadioOption('Citizen', _clientType, (v) => setState(() => _clientType = v)),
                        _buildRadioOption('Business', _clientType, (v) => setState(() => _clientType = v)),
                        _buildRadioOption('Government', _clientType, (v) => setState(() => _clientType = v)),
                        
                        const SizedBox(height: 12),
                        
                        Text(
                          'Sex',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(child: _buildRadioOption('Male', _sex, (v) => setState(() => _sex = v))),
                            const SizedBox(width: 8),
                            Expanded(child: _buildRadioOption('Female', _sex, (v) => setState(() => _sex = v))),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: _pickDate,
                                    child: AbsorbPointer(
                                      child: TextFormField(
                                        controller: _dateCtrl,
                                        style: GoogleFonts.poppins(fontSize: 12),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: const Color(0xFFE8F0FF),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Age',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _ageCtrl,
                                    keyboardType: TextInputType.number,
                                    style: GoogleFonts.poppins(fontSize: 12),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFFE8F0FF),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Text(
                          'Service Availed',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _serviceCtrl,
                          style: GoogleFonts.poppins(fontSize: 12),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFE8F0FF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Text(
                          'Region of residence',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _regionCtrl,
                          style: GoogleFonts.poppins(fontSize: 12),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFE8F0FF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
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
        
        // Right Panel - CC Questions (Dark)
        Expanded(
          child: Stack(
            children: [
              // Background
              Positioned.fill(
                child: Image.asset(
                  'assets/background.jpeg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) =>
                      Container(color: const Color(0xFF2b3e50)),
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
              
              // Content
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Instructions
                      Text(
                        'INSTRUCTIONS: Please place a Check mark (✓) in the designated box that corresponds to your answer on the Citizen\'s Charter (CC) questions. For any suggestions or complaints, please log-on to https://arta.gov.ph/, click RIA Portal Services and fill out the form that reflects the services of a government agency/office rendering a merchandise.',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.white,
                          height: 1.6,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // CC1
                      _buildCCQuestion(
                        'CC1',
                        'Which of the following best describes your awareness of a CC?',
                        _getCCOptions(1),
                        _cc1,
                        (v) => setState(() => _cc1 = v),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // CC2
                      _buildCCQuestion(
                        'CC2',
                        'If aware of CC (answered 1-3 in CC1), would you say that the CC of this office was...?',
                        _getCCOptions(2),
                        _cc2,
                        (v) => setState(() => _cc2 = v),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // CC3
                      _buildCCQuestion(
                        'CC3',
                        'If aware of CC (answered codes 1-3 in CC1), how much did the CC help you in your transaction?',
                        _getCCOptions(3),
                        _cc3,
                        (v) => setState(() => _cc3 = v),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Next Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A84FF),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Next',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
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

  Widget _buildMobileLayout() {
    // Fallback to original mobile flow
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

  Widget _buildRadioOption(String label, String? groupValue, ValueChanged<String?> onChanged) {
    return InkWell(
      onTap: () => onChanged(label),
      child: Row(
        children: [
          Transform.scale(
            scale: 0.9,
            child: Radio<String>(
              value: label,
              groupValue: groupValue,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildCCQuestion(
    String badge,
    String question,
    List<String> options,
    String? selection,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Question
          Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          
          // Options
          ...options.map((option) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: InkWell(
              onTap: () => onChanged(option),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                decoration: BoxDecoration(
                  color: selection == option
                      ? const Color(0xFFE8F0FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Transform.scale(
                      scale: 0.85,
                      child: Checkbox(
                        value: selection == option,
                        onChanged: (checked) {
                          if (checked == true) onChanged(option);
                        },
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return const Color(0xFF6366F1);
                          }
                          return Colors.grey.shade300;
                        }),
                        checkColor: Colors.white,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        option,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  List<String> _getCCOptions(int cc) {
    switch (cc) {
      case 1:
        return [
          'I know what a CC is and I saw this office\'s CC.',
          'I know what a CC is but I did NOT see this office\'s CC.',
          'I learned of the CC only when I saw this office\'s CC.',
          'I do not know what a CC is and I did not see one in this office.',
        ];
      case 2:
        return [
          'Easy to see',
          'Somewhat easy to see',
          'Difficult to see',
          'Not visible at all',
          'Not Applicable',
        ];
      case 3:
        return [
          'Helped very much',
          'Somewhat helped',
          'Did not help',
          'Not applicable',
        ];
      default:
        return [];
    }
  }
}
