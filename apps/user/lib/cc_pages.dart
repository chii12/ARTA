import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/survey_service.dart';

class CC1Page extends StatefulWidget {
  final Map<String, dynamic> formData;
  const CC1Page({super.key, required this.formData});

  @override
  State<CC1Page> createState() => _CC1PageState();
}

class _CC1PageState extends State<CC1Page> {
  String? _selection;

  @override
  void initState() {
    super.initState();
    _selection = widget.formData['cc1'] as String?;
  }

  void _next() {
    final data = Map<String, dynamic>.from(widget.formData);
    data['cc1'] = _selection;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => CC2Page(formData: data)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  Container(color: const Color(0xFF2C2C2C)),
            ),
          ),
          // Dark overlay
          Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.4))),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04,
                        vertical: MediaQuery.of(context).size.height * 0.02
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width < 420
                              ? MediaQuery.of(context).size.width * 0.92
                              : 400
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header without background
                              Column(
                                children: [
                                  Image.asset(
                                    'assets/logo_headingblk.png',
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => SizedBox(height: MediaQuery.of(context).size.height * 0.05)
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'INSTRUCTIONS: Please place a Check mark (✓) in the designated box that corresponds to your answer on the Citizen\'s Charter (CC) questions. For any suggestions or complaints, please log-on to https://arta.gov.ph/, click RIA Portal Services and fill out the form that reflects the services of a government agency/office rendering a merchandise.',
                                      textAlign: TextAlign.justify,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 15,
                                        height: 1.4
                                      )
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // White content area
                              Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12)
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // CC1 Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1),
                                    borderRadius: BorderRadius.circular(6)),
                                child: Text('CC1',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontSize: 13)),
                              ),
                              const SizedBox(height: 16),

                              // Question
                              Text(
                                  'Which of the following best describes your awareness of a CC?',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                      height: 1.4)),
                              const SizedBox(height: 20),

                              // Options
                              ..._options.map((o) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: InkWell(
                                      onTap: () => setState(
                                          () => _selection = o['value']),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 4),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Transform.scale(
                                              scale: 1.1,
                                              child: Radio<String>(
                                                value: o['value']!,
                                                groupValue: _selection,
                                                onChanged: (v) => setState(
                                                    () => _selection = v),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12.0),
                                                child: Text(o['label']!,
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 14,
                                                        color: Colors.black87,
                                                        height: 1.4)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )),

                              const SizedBox(height: 24),

                              // Buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12)),
                                    child: Text('Previous',
                                        style: GoogleFonts.poppins(
                                            color: const Color(0xFF8B7FE8),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15)),
                                  ),
                                  ElevatedButton(
                                    onPressed: _next,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF8B7FE8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 32, vertical: 12),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                    child: Text('Next',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15)),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> get _options => [
        {
          'value': '1',
          'label': 'I know what a CC is and I saw this office\'s CC.'
        },
        {
          'value': '2',
          'label': 'I know what a CC is but I did NOT see this office\'s CC.'
        },
        {
          'value': '3',
          'label': 'I learned of the CC only when I saw this office\'s CC.'
        },
        {
          'value': '4',
          'label':
              'I do not know what a CC is and I did not see one in this office.'
        },
      ];
}

class CC2Page extends StatefulWidget {
  final Map<String, dynamic> formData;
  const CC2Page({super.key, required this.formData});

  @override
  State<CC2Page> createState() => _CC2PageState();
}

class _CC2PageState extends State<CC2Page> {
  String? _selection;

  @override
  void initState() {
    super.initState();
    _selection = widget.formData['cc2'] as String?;
  }

  void _next() {
    final data = Map<String, dynamic>.from(widget.formData);
    data['cc2'] = _selection;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => CC3Page(formData: data)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  Container(color: const Color(0xFF2C2C2C)),
            ),
          ),
          // Dark overlay
          Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.4))),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04,
                        vertical: MediaQuery.of(context).size.height * 0.02
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width < 420
                              ? MediaQuery.of(context).size.width * 0.92
                              : 400
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header without background
                              Column(
                                children: [
                                  Image.asset(
                                    'assets/logo_headingblk.png',
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => SizedBox(height: MediaQuery.of(context).size.height * 0.05)
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'INSTRUCTIONS: Please place a Check mark (✓) in the designated box that corresponds to your answer on the Citizen\'s Charter (CC) questions. For any suggestions or complaints, please log-on to https://arta.gov.ph/, click RIA Portal Services and fill out the form that reflects the services of a government agency/office rendering a merchandise.',
                                      textAlign: TextAlign.justify,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 15,
                                        height: 1.4
                                      )
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // White content area
                              Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12)
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // CC2 Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1),
                                    borderRadius: BorderRadius.circular(6)),
                                child: Text('CC2',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontSize: 13)),
                              ),
                              const SizedBox(height: 16),

                              // Question
                              Text(
                                  'If aware of CC (answered 1-3 in CC1), would you say that the CC of this office was...?',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                      height: 1.4)),
                              const SizedBox(height: 20),

                              // Options
                              ...[
                                'Easy to see',
                                'Somewhat easy to see',
                                'Difficult to see',
                                'Not visible at all',
                                'Not Applicable'
                              ].map((t) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: InkWell(
                                      onTap: () =>
                                          setState(() => _selection = t),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 4),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Transform.scale(
                                              scale: 1.1,
                                              child: Radio<String>(
                                                value: t,
                                                groupValue: _selection,
                                                onChanged: (v) => setState(
                                                    () => _selection = v),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12.0),
                                                child: Text(t,
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 14,
                                                        color: Colors.black87,
                                                        height: 1.4)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )),

                              const SizedBox(height: 24),

                              // Buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12)),
                                    child: Text('Previous',
                                        style: GoogleFonts.poppins(
                                            color: const Color(0xFF8B7FE8),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15)),
                                  ),
                                  ElevatedButton(
                                    onPressed: _next,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF8B7FE8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 32, vertical: 12),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                    child: Text('Next',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15)),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CC3Page extends StatefulWidget {
  final Map<String, dynamic> formData;
  const CC3Page({super.key, required this.formData});

  @override
  State<CC3Page> createState() => _CC3PageState();
}

class _CC3PageState extends State<CC3Page> {
  String? _selection;

  @override
  void initState() {
    super.initState();
    _selection = widget.formData['cc3'] as String?;
  }

  void _next() {
    final data = Map<String, dynamic>.from(widget.formData);
    data['cc3'] = _selection;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => SQD0Page(formData: data)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  Container(color: const Color(0xFF2C2C2C)),
            ),
          ),
          // Dark overlay
          Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.4))),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04,
                        vertical: MediaQuery.of(context).size.height * 0.02
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width < 420
                              ? MediaQuery.of(context).size.width * 0.92
                              : 400
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header without background
                              Column(
                                children: [
                                  Image.asset(
                                    'assets/logo_headingblk.png',
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => SizedBox(height: MediaQuery.of(context).size.height * 0.05)
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'INSTRUCTIONS: Please place a Check mark (✓) in the designated box that corresponds to your answer on the Citizen\'s Charter (CC) questions. For any suggestions or complaints, please log-on to https://arta.gov.ph/, click RIA Portal Services and fill out the form that reflects the services of a government agency/office rendering a merchandise.',
                                      textAlign: TextAlign.justify,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 15,
                                        height: 1.4
                                      )
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // White content area
                              Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12)
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // CC3 Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1),
                                    borderRadius: BorderRadius.circular(6)),
                                child: Text('CC3',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontSize: 13)),
                              ),
                              const SizedBox(height: 16),

                              // Question
                              Text(
                                  'If aware of CC (answered codes 1-3 in CC1), how much did the CC help you in your transaction?',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                      height: 1.4)),
                              const SizedBox(height: 20),

                              // Options
                              ...[
                                'Helped very much',
                                'Somewhat helped',
                                'Did not help',
                                'Not applicable'
                              ].map((t) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: InkWell(
                                      onTap: () =>
                                          setState(() => _selection = t),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 4),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Transform.scale(
                                              scale: 1.1,
                                              child: Radio<String>(
                                                value: t,
                                                groupValue: _selection,
                                                onChanged: (v) => setState(
                                                    () => _selection = v),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12.0),
                                                child: Text(t,
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 14,
                                                        color: Colors.black87,
                                                        height: 1.4)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )),

                              const SizedBox(height: 24),

                              // Buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12)),
                                    child: Text('Previous',
                                        style: GoogleFonts.poppins(
                                            color: const Color(0xFF8B7FE8),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15)),
                                  ),
                                  ElevatedButton(
                                    onPressed: _next,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF8B7FE8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 32, vertical: 12),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                    child: Text('Next',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15)),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// SQD0 Page
class SQD0Page extends StatefulWidget {
  final Map<String, dynamic> formData;
  const SQD0Page({super.key, required this.formData});

  @override
  State<SQD0Page> createState() => _SQD0PageState();
}

class _SQD0PageState extends State<SQD0Page> {
  String? _selection;

  @override
  void initState() {
    super.initState();
    _selection = widget.formData['sqd0'] as String?;
  }

  void _next() {
    final data = Map<String, dynamic>.from(widget.formData);
    data['sqd0'] = _selection;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => SQD1Page(formData: data)));
  }

  String _getEmojiAsset() {
    if (_selection == null) {
      return 'assets/emoticons/NEITHER AGREE NOR DISAGREE-BW.png';
    }
    switch (_selection) {
      case 'STRONGLY DISAGREE':
        return 'assets/emoticons/STRONGLY DISAGREE.png';
      case 'DISAGREE':
        return 'assets/emoticons/DISAGREE.png';
      case 'NEITHER AGREE NOR DISAGREE':
        return 'assets/emoticons/NEITHER AGREE NOR DISAGREE.png';
      case 'AGREE':
        return 'assets/emoticons/AGREE.png';
      case 'STRONGLY AGREE':
        return 'assets/emoticons/STRONGLY AGREE.png';
      case 'NOT APPLICABLE':
        return 'assets/emoticons/X.png';
      default:
        return 'assets/emoticons/NEITHER AGREE NOR DISAGREE-BW.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
              child: Container(color: Colors.black.withValues(alpha: 0.4))),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04,
                        vertical: MediaQuery.of(context).size.height * 0.02
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width < 420
                              ? MediaQuery.of(context).size.width * 0.92
                              : 400
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header without background
                              Column(
                                children: [
                                  Image.asset(
                                    'assets/logo_headingblk.png',
                                    height: MediaQuery.of(context).size.height * 0.08,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => SizedBox(height: MediaQuery.of(context).size.height * 0.08)
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'Please select the best that corresponds to your answer.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 15,
                                        height: 1.4
                                      )
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // White content area
                              Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12)
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // SQD0 Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(6)),
                                        child: Text('SQD0',
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                fontSize: 13)),
                                      ),
                                      const SizedBox(height: 16),

                                  // Statement
                                  Text(
                                      'I am satisfied with the service that availed.',
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          height: 1.4)),
                                  const SizedBox(height: 16),

                                  // Emoji display
                                  Center(
                                    child: Image.asset(
                                      _getEmojiAsset(),
                                      height: 180,
                                      width: 180,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const SizedBox(
                                          height: 180, width: 180),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Options
                                  ...[
                                    'STRONGLY DISAGREE',
                                    'DISAGREE',
                                    'NEITHER AGREE NOR DISAGREE',
                                    'AGREE',
                                    'STRONGLY AGREE',
                                    'NOT APPLICABLE'
                                  ].map((t) => Padding(
                                        padding: const EdgeInsets.only(bottom: 2.0),
                                        child: InkWell(
                                          onTap: () =>
                                              setState(() => _selection = t),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 4),
                                            decoration: BoxDecoration(
                                              color: _selection == t
                                                  ? const Color(0xFFE8F0FF)
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 1.1,
                                                  child: Radio<String>(
                                                    value: t,
                                                    groupValue: _selection,
                                                    onChanged: (v) => setState(
                                                        () => _selection = v),
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(t,
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          color: Colors.black87,
                                                          fontWeight: _selection == t
                                                              ? FontWeight.w600
                                                              : FontWeight.normal)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )),

                                  const SizedBox(height: 24),

                                  // Buttons
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 12)),
                                        child: Text('Previous',
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFF8B7FE8),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15)),
                                      ),
                                      ElevatedButton(
                                        onPressed: _next,
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF8B7FE8),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 32, vertical: 12),
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8))),
                                        child: Text('Next',
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15)),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// SQD1 Page
class SQD1Page extends StatefulWidget {
  final Map<String, dynamic> formData;
  const SQD1Page({super.key, required this.formData});

  @override
  State<SQD1Page> createState() => _SQD1PageState();
}

class _SQD1PageState extends State<SQD1Page> {
  String? _selection;

  @override
  void initState() {
    super.initState();
    _selection = widget.formData['sqd1'] as String?;
  }

  void _next() {
    final data = Map<String, dynamic>.from(widget.formData);
    data['sqd1'] = _selection;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => SQD2Page(formData: data)));
  }

  String _getEmojiAsset() {
    if (_selection == null) {
      return 'assets/emoticons/NEITHER AGREE NOR DISAGREE-BW.png';
    }
    switch (_selection) {
      case 'STRONGLY DISAGREE':
        return 'assets/emoticons/STRONGLY DISAGREE.png';
      case 'DISAGREE':
        return 'assets/emoticons/DISAGREE.png';
      case 'NEITHER AGREE NOR DISAGREE':
        return 'assets/emoticons/NEITHER AGREE NOR DISAGREE.png';
      case 'AGREE':
        return 'assets/emoticons/AGREE.png';
      case 'STRONGLY AGREE':
        return 'assets/emoticons/STRONGLY AGREE.png';
      case 'NOT APPLICABLE':
        return 'assets/emoticons/X.png';
      default:
        return 'assets/emoticons/NEITHER AGREE NOR DISAGREE-BW.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
              child: Container(color: Colors.black.withValues(alpha: 0.4))),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04,
                        vertical: MediaQuery.of(context).size.height * 0.02
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width < 420
                              ? MediaQuery.of(context).size.width * 0.92
                              : 400
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header without background
                              Column(
                                children: [
                                  Image.asset(
                                    'assets/logo_headingblk.png',
                                    height: MediaQuery.of(context).size.height * 0.08,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => SizedBox(height: MediaQuery.of(context).size.height * 0.08)
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'Please select the best that corresponds to your answer.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 15,
                                        height: 1.4
                                      )
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // White content area
                              Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12)
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(6)),
                                        child: Text('SQD1',
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                fontSize: 13)),
                                      ),
                                      const SizedBox(height: 16),
                                  Text(
                                      'I spent a reasonable amount of time for my transaction',
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          height: 1.4)),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: Image.asset(
                                      _getEmojiAsset(),
                                      height: 180,
                                      width: 180,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const SizedBox(
                                          height: 180, width: 180),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...[
                                    'STRONGLY DISAGREE',
                                    'DISAGREE',
                                    'NEITHER AGREE NOR DISAGREE',
                                    'AGREE',
                                    'STRONGLY AGREE',
                                    'NOT APPLICABLE'
                                  ].map((t) => Padding(
                                        padding: const EdgeInsets.only(bottom: 2.0),
                                        child: InkWell(
                                          onTap: () =>
                                              setState(() => _selection = t),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 4),
                                            decoration: BoxDecoration(
                                              color: _selection == t
                                                  ? const Color(0xFFE8F0FF)
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 1.1,
                                                  child: Radio<String>(
                                                    value: t,
                                                    groupValue: _selection,
                                                    onChanged: (v) => setState(
                                                        () => _selection = v),
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(t,
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          color: Colors.black87,
                                                          fontWeight: _selection == t
                                                              ? FontWeight.w600
                                                              : FontWeight.normal)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 12)),
                                        child: Text('Previous',
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFF8B7FE8),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15)),
                                      ),
                                      ElevatedButton(
                                        onPressed: _next,
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF8B7FE8),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 32, vertical: 12),
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8))),
                                        child: Text('Next',
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15)),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// SQD2 through SQD8 pages
class SQD2Page extends StatefulWidget {
  final Map<String, dynamic> formData;
  const SQD2Page({super.key, required this.formData});
  @override
  State<SQD2Page> createState() => _SQD2PageState();
}

class _SQD2PageState extends State<SQD2Page> {
  String? _selection;
  @override
  void initState() {
    super.initState();
    _selection = widget.formData['sqd2'] as String?;
  }
  void _next() {
    final data = Map<String, dynamic>.from(widget.formData);
    data['sqd2'] = _selection;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => SQD3Page(formData: data)));
  }
  String _getEmojiAsset() {
    if (_selection == null) return 'assets/emoticons/NEITHER AGREE NOR DISAGREE-BW.png';
    switch (_selection) {
      case 'STRONGLY DISAGREE': return 'assets/emoticons/STRONGLY DISAGREE.png';
      case 'DISAGREE': return 'assets/emoticons/DISAGREE.png';
      case 'NEITHER AGREE NOR DISAGREE': return 'assets/emoticons/NEITHER AGREE NOR DISAGREE.png';
      case 'AGREE': return 'assets/emoticons/AGREE.png';
      case 'STRONGLY AGREE': return 'assets/emoticons/STRONGLY AGREE.png';
      case 'NOT APPLICABLE': return 'assets/emoticons/X.png';
      default: return 'assets/emoticons/NEITHER AGREE NOR DISAGREE-BW.png';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.jpeg', fit: BoxFit.cover, errorBuilder: (context, error, stack) => Container(color: const Color(0xFF2C2C2C)))),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.4))),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04, vertical: MediaQuery.of(context).size.height * 0.02),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width < 420 ? MediaQuery.of(context).size.width * 0.92 : 400),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Image.asset('assets/logo_headingblk.png', height: MediaQuery.of(context).size.height * 0.08, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('Please select the best that corresponds to your answer.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500, height: 1.4)),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                              Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)), child: Text('SQD2', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13))),
                                  const SizedBox(height: 12),
                                  Text('The office followed the transaction\'s requirements and steps based on the information provided', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.4)),
                                  const SizedBox(height: 16),
                                  Center(child: Image.asset(_getEmojiAsset(), height: 180, width: 180, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox(height: 180, width: 180))),
                                  const SizedBox(height: 16),
                                  ...['STRONGLY DISAGREE', 'DISAGREE', 'NEITHER AGREE NOR DISAGREE', 'AGREE', 'STRONGLY AGREE', 'NOT APPLICABLE'].map((t) => Padding(padding: const EdgeInsets.only(bottom: 2.0), child: InkWell(onTap: () => setState(() => _selection = t), borderRadius: BorderRadius.circular(8), child: Container(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), decoration: BoxDecoration(color: _selection == t ? const Color(0xFFE8F0FF) : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: Row(children: [Transform.scale(scale: 1.1, child: Radio<String>(value: t, groupValue: _selection, onChanged: (v) => setState(() => _selection = v), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)), const SizedBox(width: 8), Expanded(child: Text(t, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, fontWeight: _selection == t ? FontWeight.w600 : FontWeight.normal)))]))))),
                                  const SizedBox(height: 24),
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [TextButton(onPressed: () => Navigator.of(context).pop(), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: Text('Previous', style: GoogleFonts.poppins(color: const Color(0xFF8B7FE8), fontWeight: FontWeight.w600, fontSize: 15))), ElevatedButton(onPressed: _next, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B7FE8), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text('Next', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)))])
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
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SQD3Page extends StatefulWidget {
  final Map<String, dynamic> formData;
  const SQD3Page({super.key, required this.formData});
  @override
  State<SQD3Page> createState() => _SQD3PageState();
}

class _SQD3PageState extends State<SQD3Page> {
  String? _selection;
  @override
  void initState() {
    super.initState();
    _selection = widget.formData['sqd3'] as String?;
  }
  void _next() {
    final data = Map<String, dynamic>.from(widget.formData);
    data['sqd3'] = _selection;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => SQD4Page(formData: data)));
  }
  String _getEmojiAsset() {
    if (_selection == null) return 'assets/emoticons/NEITHER AGREE NOR DISAGREE-BW.png';
    switch (_selection) {
      case 'STRONGLY DISAGREE': return 'assets/emoticons/STRONGLY DISAGREE.png';
      case 'DISAGREE': return 'assets/emoticons/DISAGREE.png';
      case 'NEITHER AGREE NOR DISAGREE': return 'assets/emoticons/NEITHER AGREE NOR DISAGREE.png';
      case 'AGREE': return 'assets/emoticons/AGREE.png';
      case 'STRONGLY AGREE': return 'assets/emoticons/STRONGLY AGREE.png';
      case 'NOT APPLICABLE': return 'assets/emoticons/X.png';
      default: return 'assets/emoticons/NEITHER AGREE NOR DISAGREE-BW.png';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.jpeg', fit: BoxFit.cover, errorBuilder: (context, error, stack) => Container(color: const Color(0xFF2C2C2C)))),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.4))),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04, vertical: MediaQuery.of(context).size.height * 0.02),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width < 420 ? MediaQuery.of(context).size.width * 0.92 : 400),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Image.asset('assets/logo_headingblk.png', height: MediaQuery.of(context).size.height * 0.08, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('Please select the best that corresponds to your answer.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500, height: 1.4)),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                              Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)), child: Text('SQD3', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13))),
                                  const SizedBox(height: 12),
                                  Text('The steps (including payment) I needed to do for my transaction were easy and simple.', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.4)),
                                  const SizedBox(height: 16),
                                  Center(child: Image.asset(_getEmojiAsset(), height: 180, width: 180, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox(height: 180, width: 180))),
                                  const SizedBox(height: 16),
                                  ...['STRONGLY DISAGREE', 'DISAGREE', 'NEITHER AGREE NOR DISAGREE', 'AGREE', 'STRONGLY AGREE', 'NOT APPLICABLE'].map((t) => Padding(padding: const EdgeInsets.only(bottom: 2.0), child: InkWell(onTap: () => setState(() => _selection = t), borderRadius: BorderRadius.circular(8), child: Container(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), decoration: BoxDecoration(color: _selection == t ? const Color(0xFFE8F0FF) : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: Row(children: [Transform.scale(scale: 1.1, child: Radio<String>(value: t, groupValue: _selection, onChanged: (v) => setState(() => _selection = v), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)), const SizedBox(width: 8), Expanded(child: Text(t, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, fontWeight: _selection == t ? FontWeight.w600 : FontWeight.normal)))]))))),
                                  const SizedBox(height: 24),
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [TextButton(onPressed: () => Navigator.of(context).pop(), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: Text('Previous', style: GoogleFonts.poppins(color: const Color(0xFF8B7FE8), fontWeight: FontWeight.w600, fontSize: 15))), ElevatedButton(onPressed: _next, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B7FE8), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text('Next', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)))])
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
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SQD4Page extends StatefulWidget {
  final Map<String, dynamic> formData;
  const SQD4Page({super.key, required this.formData});
  @override
  State<SQD4Page> createState() => _SQD4PageState();
}

class _SQD4PageState extends State<SQD4Page> {
  String? _selection;
  @override
  void initState() {
    super.initState();
    _selection = widget.formData['sqd4'] as String?;
  }
  void _next() {
    final data = Map<String, dynamic>.from(widget.formData);
    data['sqd4'] = _selection;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => SQD5Page(formData: data)));
  }
  String _getEmojiAsset() {
    if (_selection == null) return 'assets/emoticons/NEITHER AGREE NOR DISAGREE-BW.png';
    switch (_selection) {
      case 'STRONGLY DISAGREE': return 'assets/emoticons/STRONGLY DISAGREE.png';
      case 'DISAGREE': return 'assets/emoticons/DISAGREE.png';
      case 'NEITHER AGREE NOR DISAGREE': return 'assets/emoticons/NEITHER AGREE NOR DISAGREE.png';
      case 'AGREE': return 'assets/emoticons/AGREE.png';
      case 'STRONGLY AGREE': return 'assets/emoticons/STRONGLY AGREE.png';
      case 'NOT APPLICABLE': return 'assets/emoticons/X.png';
      default: return 'assets/emoticons/NEITHER AGREE NOR DISAGREE-BW.png';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.jpeg', fit: BoxFit.cover, errorBuilder: (context, error, stack) => Container(color: const Color(0xFF2C2C2C)))),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.4))),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04, vertical: MediaQuery.of(context).size.height * 0.02),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width < 420 ? MediaQuery.of(context).size.width * 0.92 : 400),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Image.asset('assets/logo_headingblk.png', height: MediaQuery.of(context).size.height * 0.08, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('Please select the best that corresponds to your answer.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500, height: 1.4)),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                              Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)), child: Text('SQD4', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13))),
                                  const SizedBox(height: 12),
                                  Text('I easily found information about my transaction from the office or its website.', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.4)),
                                  const SizedBox(height: 16),
                                  Center(child: Image.asset(_getEmojiAsset(), height: 180, width: 180, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox(height: 180, width: 180))),
                                  const SizedBox(height: 16),
                                  ...['STRONGLY DISAGREE', 'DISAGREE', 'NEITHER AGREE NOR DISAGREE', 'AGREE', 'STRONGLY AGREE', 'NOT APPLICABLE'].map((t) => Padding(padding: const EdgeInsets.only(bottom: 2.0), child: InkWell(onTap: () => setState(() => _selection = t), borderRadius: BorderRadius.circular(8), child: Container(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), decoration: BoxDecoration(color: _selection == t ? const Color(0xFFE8F0FF) : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: Row(children: [Transform.scale(scale: 1.1, child: Radio<String>(value: t, groupValue: _selection, onChanged: (v) => setState(() => _selection = v), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)), const SizedBox(width: 8), Expanded(child: Text(t, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, fontWeight: _selection == t ? FontWeight.w600 : FontWeight.normal)))]))))),
                                  const SizedBox(height: 24),
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [TextButton(onPressed: () => Navigator.of(context).pop(), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: Text('Previous', style: GoogleFonts.poppins(color: const Color(0xFF8B7FE8), fontWeight: FontWeight.w600, fontSize: 15))), ElevatedButton(onPressed: _next, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B7FE8), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text('Next', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)))])
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
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SQD5Page extends StatefulWidget {
  final Map<String, dynamic> formData;
  const SQD5Page({super.key, required this.formData});
  @override
  State<SQD5Page> createState() => _SQD5PageState();
}

class _SQD5PageState extends State<SQD5Page> {
  String? _selection;
  @override
  void initState() {
    super.initState();
    _selection = widget.formData['sqd5'] as String?;
  }
  void _next() {
    final data = Map<String, dynamic>.from(widget.formData);
    data['sqd5'] = _selection;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => SQD6Page(formData: data)));
  }
  String _getEmojiAsset() {
    if (_selection == null) return 'assets/emoticons/NEITHER AGREE NOR DISAGREE-BW.png';
    switch (_selection) {
      case 'STRONGLY DISAGREE': return 'assets/emoticons/STRONGLY DISAGREE.png';
      case 'DISAGREE': return 'assets/emoticons/DISAGREE.png';
      case 'NEITHER AGREE NOR DISAGREE': return 'assets/emoticons/NEITHER AGREE NOR DISAGREE.png';
      case 'AGREE': return 'assets/emoticons/AGREE.png';
      case 'STRONGLY AGREE': return 'assets/emoticons/STRONGLY AGREE.png';
      case 'NOT APPLICABLE': return 'assets/emoticons/X.png';
      default: return 'assets/emoticons/NEITHER AGREE NOR DISAGREE-BW.png';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.jpeg', fit: BoxFit.cover, errorBuilder: (context, error, stack) => Container(color: const Color(0xFF2C2C2C)))),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.4))),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04, vertical: MediaQuery.of(context).size.height * 0.02),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width < 420 ? MediaQuery.of(context).size.width * 0.92 : 400),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Image.asset('assets/logo_headingblk.png', height: MediaQuery.of(context).size.height * 0.08, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('Please select the best that corresponds to your answer.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500, height: 1.4)),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                              Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)), child: Text('SQD5', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13))),
                                  const SizedBox(height: 12),
                                  Text('I paid a reasonable amount of fees for my transaction. (If service was free, mark the N/A instead.)', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.4)),
                                  const SizedBox(height: 16),
                                  Center(child: Image.asset(_getEmojiAsset(), height: 180, width: 180, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox(height: 180, width: 180))),
                                  const SizedBox(height: 16),
                                  ...['STRONGLY DISAGREE', 'DISAGREE', 'NEITHER AGREE NOR DISAGREE', 'AGREE', 'STRONGLY AGREE', 'NOT APPLICABLE'].map((t) => Padding(padding: const EdgeInsets.only(bottom: 2.0), child: InkWell(onTap: () => setState(() => _selection = t), borderRadius: BorderRadius.circular(8), child: Container(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), decoration: BoxDecoration(color: _selection == t ? const Color(0xFFE8F0FF) : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: Row(children: [Transform.scale(scale: 1.1, child: Radio<String>(value: t, groupValue: _selection, onChanged: (v) => setState(() => _selection = v), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)), const SizedBox(width: 8), Expanded(child: Text(t, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, fontWeight: _selection == t ? FontWeight.w600 : FontWeight.normal)))]))))),
                                  const SizedBox(height: 24),
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [TextButton(onPressed: () => Navigator.of(context).pop(), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: Text('Previous', style: GoogleFonts.poppins(color: const Color(0xFF8B7FE8), fontWeight: FontWeight.w600, fontSize: 15))), ElevatedButton(onPressed: _next, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B7FE8), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text('Next', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)))])
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
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SQD6Page extends StatefulWidget {
  final Map<String, dynamic> formData;
  const SQD6Page({super.key, required this.formData});
  @override
  State<SQD6Page> createState() => _SQD6PageState();
}

class _SQD6PageState extends State<SQD6Page> {
  String? _selection;
  @override
  void initState() {
    super.initState();
    _selection = widget.formData['sqd6'] as String?;
  }
  void _next() {
    final data = Map<String, dynamic>.from(widget.formData);
    data['sqd6'] = _selection;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => SQD7Page(formData: data)));
  }
  String _getEmojiAsset() {
    if (_selection == null) return 'assets/emoticons/NEITHER AGREE NOR DISAGREE-BW.png';
    switch (_selection) {
      case 'STRONGLY DISAGREE': return 'assets/emoticons/STRONGLY DISAGREE.png';
      case 'DISAGREE': return 'assets/emoticons/DISAGREE.png';
      case 'NEITHER AGREE NOR DISAGREE': return 'assets/emoticons/NEITHER AGREE NOR DISAGREE.png';
      case 'AGREE': return 'assets/emoticons/AGREE.png';
      case 'STRONGLY AGREE': return 'assets/emoticons/STRONGLY AGREE.png';
      case 'NOT APPLICABLE': return 'assets/emoticons/X.png';
      default: return 'assets/emoticons/NEITHER AGREE NOR DISAGREE-BW.png';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.jpeg', fit: BoxFit.cover, errorBuilder: (context, error, stack) => Container(color: const Color(0xFF2C2C2C)))),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.4))),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04, vertical: MediaQuery.of(context).size.height * 0.02),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width < 420 ? MediaQuery.of(context).size.width * 0.92 : 400),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Image.asset('assets/logo_headingblk.png', height: MediaQuery.of(context).size.height * 0.08, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('Please select the best that corresponds to your answer.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500, height: 1.4)),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                              Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)), child: Text('SQD6', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13))),
                                  const SizedBox(height: 12),
                                  Text('I feel the office was fair to everyone, or "walang palakasan", during my transaction.', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.4)),
                                  const SizedBox(height: 16),
                                  Center(child: Image.asset(_getEmojiAsset(), height: 180, width: 180, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox(height: 180, width: 180))),
                                  const SizedBox(height: 16),
                                  ...['STRONGLY DISAGREE', 'DISAGREE', 'NEITHER AGREE NOR DISAGREE', 'AGREE', 'STRONGLY AGREE', 'NOT APPLICABLE'].map((t) => Padding(padding: const EdgeInsets.only(bottom: 2.0), child: InkWell(onTap: () => setState(() => _selection = t), borderRadius: BorderRadius.circular(8), child: Container(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), decoration: BoxDecoration(color: _selection == t ? const Color(0xFFE8F0FF) : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: Row(children: [Transform.scale(scale: 1.1, child: Radio<String>(value: t, groupValue: _selection, onChanged: (v) => setState(() => _selection = v), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)), const SizedBox(width: 8), Expanded(child: Text(t, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, fontWeight: _selection == t ? FontWeight.w600 : FontWeight.normal)))]))))),
                                  const SizedBox(height: 24),
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [TextButton(onPressed: () => Navigator.of(context).pop(), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: Text('Previous', style: GoogleFonts.poppins(color: const Color(0xFF8B7FE8), fontWeight: FontWeight.w600, fontSize: 15))), ElevatedButton(onPressed: _next, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B7FE8), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text('Next', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)))])
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
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SQD7Page extends StatefulWidget {
  final Map<String, dynamic> formData;
  const SQD7Page({super.key, required this.formData});
  @override
  State<SQD7Page> createState() => _SQD7PageState();
}

class _SQD7PageState extends State<SQD7Page> {
  String? _selection;
  @override
  void initState() {
    super.initState();
    _selection = widget.formData['sqd7'] as String?;
  }
  void _next() {
    final data = Map<String, dynamic>.from(widget.formData);
    data['sqd7'] = _selection;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => SQD8Page(formData: data)));
  }
  String _getEmojiAsset() {
    if (_selection == null) return 'assets/emoticons/NEITHER AGREE NOR DISAGREE-BW.png';
    switch (_selection) {
      case 'STRONGLY DISAGREE': return 'assets/emoticons/STRONGLY DISAGREE.png';
      case 'DISAGREE': return 'assets/emoticons/DISAGREE.png';
      case 'NEITHER AGREE NOR DISAGREE': return 'assets/emoticons/NEITHER AGREE NOR DISAGREE.png';
      case 'AGREE': return 'assets/emoticons/AGREE.png';
      case 'STRONGLY AGREE': return 'assets/emoticons/STRONGLY AGREE.png';
      case 'NOT APPLICABLE': return 'assets/emoticons/X.png';
      default: return 'assets/emoticons/NEITHER AGREE NOR DISAGREE-BW.png';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.jpeg', fit: BoxFit.cover, errorBuilder: (context, error, stack) => Container(color: const Color(0xFF2C2C2C)))),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.4))),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04, vertical: MediaQuery.of(context).size.height * 0.02),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width < 420 ? MediaQuery.of(context).size.width * 0.92 : 400),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Image.asset('assets/logo_headingblk.png', height: MediaQuery.of(context).size.height * 0.08, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('Please select the best that corresponds to your answer.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500, height: 1.4)),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                              Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)), child: Text('SQD7', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13))),
                                  const SizedBox(height: 12),
                                  Text('I was treated courteously by the staff, and (if asked for help) he/she/they was helpful.', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.4)),
                                  const SizedBox(height: 16),
                                  Center(child: Image.asset(_getEmojiAsset(), height: 180, width: 180, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox(height: 180, width: 180))),
                                  const SizedBox(height: 16),
                                  ...['STRONGLY DISAGREE', 'DISAGREE', 'NEITHER AGREE NOR DISAGREE', 'AGREE', 'STRONGLY AGREE', 'NOT APPLICABLE'].map((t) => Padding(padding: const EdgeInsets.only(bottom: 2.0), child: InkWell(onTap: () => setState(() => _selection = t), borderRadius: BorderRadius.circular(8), child: Container(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), decoration: BoxDecoration(color: _selection == t ? const Color(0xFFE8F0FF) : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: Row(children: [Transform.scale(scale: 1.1, child: Radio<String>(value: t, groupValue: _selection, onChanged: (v) => setState(() => _selection = v), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)), const SizedBox(width: 8), Expanded(child: Text(t, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, fontWeight: _selection == t ? FontWeight.w600 : FontWeight.normal)))]))))),
                                  const SizedBox(height: 24),
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [TextButton(onPressed: () => Navigator.of(context).pop(), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: Text('Previous', style: GoogleFonts.poppins(color: const Color(0xFF8B7FE8), fontWeight: FontWeight.w600, fontSize: 15))), ElevatedButton(onPressed: _next, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B7FE8), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text('Next', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)))])
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
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SQD8Page extends StatefulWidget {
  final Map<String, dynamic> formData;
  const SQD8Page({super.key, required this.formData});
  @override
  State<SQD8Page> createState() => _SQD8PageState();
}

class _SQD8PageState extends State<SQD8Page> {
  String? _selection;
  @override
  void initState() {
    super.initState();
    _selection = widget.formData['sqd8'] as String?;
  }
  
  void _next() {
    final data = Map<String, dynamic>.from(widget.formData);
    data['sqd8'] = _selection;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => SuggestionsPage(formData: data)));
  }
  
  String _getEmojiAsset() {
    if (_selection == null) return 'assets/emoticons/NEITHER AGREE NOR DISAGREE-BW.png';
    switch (_selection) {
      case 'STRONGLY DISAGREE': return 'assets/emoticons/STRONGLY DISAGREE.png';
      case 'DISAGREE': return 'assets/emoticons/DISAGREE.png';
      case 'NEITHER AGREE NOR DISAGREE': return 'assets/emoticons/NEITHER AGREE NOR DISAGREE.png';
      case 'AGREE': return 'assets/emoticons/AGREE.png';
      case 'STRONGLY AGREE': return 'assets/emoticons/STRONGLY AGREE.png';
      case 'NOT APPLICABLE': return 'assets/emoticons/X.png';
      default: return 'assets/emoticons/NEITHER AGREE NOR DISAGREE-BW.png';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.jpeg', fit: BoxFit.cover, errorBuilder: (context, error, stack) => Container(color: const Color(0xFF2C2C2C)))),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.4))),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04, vertical: MediaQuery.of(context).size.height * 0.02),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width < 420 ? MediaQuery.of(context).size.width * 0.92 : 400),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Image.asset('assets/logo_headingblk.png', height: MediaQuery.of(context).size.height * 0.08, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('Please select the best that corresponds to your answer.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500, height: 1.4)),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                              Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)), child: Text('SQD8', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13))),
                                  const SizedBox(height: 12),
                                  Text('I got what I needed from the government office, or (if denied) requirements were sufficiently explained to me.', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.4)),
                                  const SizedBox(height: 16),
                                  Center(child: Image.asset(_getEmojiAsset(), height: 180, width: 180, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox(height: 180, width: 180))),
                                  const SizedBox(height: 16),
                                  ...['STRONGLY DISAGREE', 'DISAGREE', 'NEITHER AGREE NOR DISAGREE', 'AGREE', 'STRONGLY AGREE', 'NOT APPLICABLE'].map((t) => Padding(padding: const EdgeInsets.only(bottom: 2.0), child: InkWell(onTap: () => setState(() => _selection = t), borderRadius: BorderRadius.circular(8), child: Container(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), decoration: BoxDecoration(color: _selection == t ? const Color(0xFFE8F0FF) : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: Row(children: [Transform.scale(scale: 1.1, child: Radio<String>(value: t, groupValue: _selection, onChanged: (v) => setState(() => _selection = v), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)), const SizedBox(width: 8), Expanded(child: Text(t, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, fontWeight: _selection == t ? FontWeight.w600 : FontWeight.normal)))]))))),
                                  const SizedBox(height: 24),
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [TextButton(onPressed: () => Navigator.of(context).pop(), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: Text('Previous', style: GoogleFonts.poppins(color: const Color(0xFF8B7FE8), fontWeight: FontWeight.w600, fontSize: 15))), ElevatedButton(onPressed: _next, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B7FE8), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text('Next', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)))])
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
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Suggestions Page
class SuggestionsPage extends StatefulWidget {
  final Map<String, dynamic> formData;
  const SuggestionsPage({super.key, required this.formData});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  final TextEditingController _suggestionsCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  bool get _allQuestionsAnswered {
    final data = widget.formData;
    return data['sqd0'] != null &&
           data['sqd1'] != null &&
           data['sqd2'] != null &&
           data['sqd3'] != null &&
           data['sqd4'] != null &&
           data['sqd5'] != null &&
           data['sqd6'] != null &&
           data['sqd7'] != null &&
           data['sqd8'] != null;
  }

  @override
  void dispose() {
    _suggestionsCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _showThankYouDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'THANK YOU FOR\nYOUR HONEST\nREVIEW!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailCtrl,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'email (optional) _______',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await _submitAll();
                  if (!mounted) return;
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const ResponseRecordedPage())
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'Done',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitAll() async {
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
      sqd0: widget.formData['sqd0'] as String?,
      sqd1: widget.formData['sqd1'] as String?,
      sqd2: widget.formData['sqd2'] as String?,
      sqd3: widget.formData['sqd3'] as String?,
      sqd4: widget.formData['sqd4'] as String?,
      sqd5: widget.formData['sqd5'] as String?,
      sqd6: widget.formData['sqd6'] as String?,
      sqd7: widget.formData['sqd7'] as String?,
      sqd8: widget.formData['sqd8'] as String?,
      suggestions: _suggestionsCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
    );

    // Submit to backend (currently saves locally)
    final success = await SurveyService.submitSurveyToAPI(surveyData);
    
    if (!mounted) return;
    
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save response'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
              child: Container(color: Colors.black.withValues(alpha: 0.4))),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04,
                        vertical: MediaQuery.of(context).size.height * 0.02
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width < 420
                              ? MediaQuery.of(context).size.width * 0.92
                              : 400
                          ),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Image.asset('assets/logo_headingblk.png', height: MediaQuery.of(context).size.height * 0.08, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('For SQD 0-8. Please select the best that corresponds to your answer.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500, height: 1.4)),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                              Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                                    child: Text('SQD', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13)),
                                  ),
                                  const SizedBox(height: 16),
                                  // Statement
                                  Text(
                                      'I am satisfied with the service that availed.',
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          height: 1.4)),
                                  const SizedBox(height: 16),

                                  // Text input field
                                  TextFormField(
                                    controller: _suggestionsCtrl,
                                    maxLines: 6,
                                    style: GoogleFonts.poppins(fontSize: 14),
                                    decoration: InputDecoration(
                                      labelText: 'Optional',
                                      labelStyle: GoogleFonts.poppins(
                                          color: Colors.grey,
                                          fontSize: 14),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 14),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Buttons
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 12)),
                                        child: Text('Previous',
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFF8B7FE8),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15)),
                                      ),
                                      ElevatedButton(
                                        onPressed: _allQuestionsAnswered ? _showThankYouDialog : null,
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                _allQuestionsAnswered ? const Color(0xFF00C853) : Colors.grey,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 32, vertical: 12),
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8))),
                                        child: Text('Submit',
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15)),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ResponseRecordedPage extends StatelessWidget {
  const ResponseRecordedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
              child: Container(color: Colors.black.withValues(alpha: 0.4))),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo_headingblk.png',
                      height: MediaQuery.of(context).size.height * 0.1,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 32),
                    Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF00C853),
                              size: 80,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Your response is recorded',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Thank you for your feedback!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00C853),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 48, vertical: 14),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                'Return to Home',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
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
            ),
          ),
        ],
      ),
    );
  }
}

class SubmissionSuccessPage extends StatelessWidget {
  const SubmissionSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black87),
          elevation: 0),
      body: Center(
          child: Text('Thank you! Your response has been recorded.',
              style: GoogleFonts.poppins(fontSize: 16))),
    );
  }
}
