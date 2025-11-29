import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cc_pages.dart';
import 'survey_cc_desktop.dart';
import 'dynamic_cc_page.dart';

class SurveyFormPage extends StatefulWidget {
  final List<Map<String, dynamic>>? customQuestions;
  final Map<String, dynamic>? surveyData;
  
  const SurveyFormPage({super.key, this.customQuestions, this.surveyData});

  @override
  State<SurveyFormPage> createState() => _SurveyFormPageState();
}

class _SurveyFormPageState extends State<SurveyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();
  final TextEditingController _ageCtrl = TextEditingController();
  final TextEditingController _regionCtrl = TextEditingController();
  final TextEditingController _serviceCtrl = TextEditingController();

  // Client type radio button
  String? _clientType;

  // Sex radio
  String? _sex;

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    // Use desktop layout for wide screens
    if (size.width > 900) {
      return const SurveyCCDesktop();
    }
    
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
                          vertical: MediaQuery.of(context).size.height * 0.02),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width < 420
                                  ? MediaQuery.of(context).size.width - 32
                                  : 400),
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Header with logo
                                Image.asset('assets/logo_heading.png',
                                    height: MediaQuery.of(context).size.height *
                                        0.05,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.05)),

                                // White content area with form
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(12),
                                          bottomRight: Radius.circular(12))),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // CSM Description Text
                                        Text(
                                            'This Client Satisfaction Measurement (CSM) tracks the customer experience of government offices. Your feedback will be kept confidential recently concluded and you transaction always will help this office provide a better service. Personal information shared will have the option',
                                            textAlign: TextAlign.justify,
                                            style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.black87,
                                                height: 1.5)),
                                        const SizedBox(height: 20),

                                        Text('Name',
                                            style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.black87)),
                                        const SizedBox(height: 6),
                                        TextFormField(
                                          controller: _nameCtrl,
                                          style: GoogleFonts.poppins(),
                                          decoration: InputDecoration(
                                            hintText: 'Optional',
                                            filled: true,
                                            fillColor: const Color(0xFFE8F0FF),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide.none),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 14),
                                          ),
                                        ),

                                        const SizedBox(height: 12),

                                        // Client Type & Sex row
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Client Type',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              color: Colors
                                                                  .black87)),
                                                  const SizedBox(height: 6),
                                                  InkWell(
                                                    onTap: () => setState(() => _clientType = 'Citizen'),
                                                    child: Row(
                                                      children: [
                                                        Radio<String>(
                                                          value: 'Citizen',
                                                          groupValue: _clientType,
                                                          onChanged: (v) => setState(() => _clientType = v),
                                                        ),
                                                        Text('Citizen',
                                                            style: GoogleFonts.poppins(fontSize: 13)),
                                                      ],
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () => setState(() => _clientType = 'Business'),
                                                    child: Row(
                                                      children: [
                                                        Radio<String>(
                                                          value: 'Business',
                                                          groupValue: _clientType,
                                                          onChanged: (v) => setState(() => _clientType = v),
                                                        ),
                                                        Text('Business',
                                                            style: GoogleFonts.poppins(fontSize: 13)),
                                                      ],
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () => setState(() => _clientType = 'Government'),
                                                    child: Row(
                                                      children: [
                                                        Radio<String>(
                                                          value: 'Government',
                                                          groupValue: _clientType,
                                                          onChanged: (v) => setState(() => _clientType = v),
                                                        ),
                                                        Text('Government',
                                                            style: GoogleFonts.poppins(fontSize: 13)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Sex',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              color: Colors
                                                                  .black87)),
                                                  const SizedBox(height: 6),
                                                  InkWell(
                                                    onTap: () => setState(
                                                        () => _sex = 'Male'),
                                                    child: Row(
                                                      children: [
                                                        Radio<String>(
                                                          value: 'Male',
                                                          groupValue: _sex,
                                                          onChanged: (v) =>
                                                              setState(() =>
                                                                  _sex = v),
                                                        ),
                                                        Text('Male',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        13)),
                                                      ],
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () => setState(
                                                        () => _sex = 'Female'),
                                                    child: Row(
                                                      children: [
                                                        Radio<String>(
                                                          value: 'Female',
                                                          groupValue: _sex,
                                                          onChanged: (v) =>
                                                              setState(() =>
                                                                  _sex = v),
                                                        ),
                                                        Text('Female',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        13)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 8),

                                        // Date & Age
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Date',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13)),
                                                  const SizedBox(height: 6),
                                                  GestureDetector(
                                                    onTap: _pickDate,
                                                    child: AbsorbPointer(
                                                      child: TextFormField(
                                                        controller: _dateCtrl,
                                                        decoration:
                                                            InputDecoration(
                                                          filled: true,
                                                          fillColor:
                                                              const Color(
                                                                  0xFFE8F0FF),
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              borderSide:
                                                                  BorderSide
                                                                      .none),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 14),
                                                        ),
                                                        style: GoogleFonts
                                                            .poppins(),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Age',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13)),
                                                  const SizedBox(height: 6),
                                                  TextFormField(
                                                    controller: _ageCtrl,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: const Color(
                                                          0xFFE8F0FF),
                                                      border:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              borderSide:
                                                                  BorderSide
                                                                      .none),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 12,
                                                              vertical: 14),
                                                    ),
                                                    style:
                                                        GoogleFonts.poppins(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 12),

                                        // Region
                                        Text('Region of residence',
                                            style: GoogleFonts.poppins(
                                                fontSize: 13)),
                                        const SizedBox(height: 6),
                                        TextFormField(
                                          controller: _regionCtrl,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: const Color(0xFFE8F0FF),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide.none),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 14),
                                          ),
                                          style: GoogleFonts.poppins(),
                                        ),

                                        const SizedBox(height: 12),

                                        // Service Availed
                                        Text('Service Availed',
                                            style: GoogleFonts.poppins(
                                                fontSize: 13)),
                                        const SizedBox(height: 6),
                                        TextFormField(
                                          controller: _serviceCtrl,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: const Color(0xFFE8F0FF),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide.none),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 14),
                                          ),
                                          style: GoogleFonts.poppins(),
                                        ),

                                        const SizedBox(height: 20),

                                        // Next button
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: SizedBox(
                                            width: 110,
                                            height: 42,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                final data = <String, dynamic>{
                                                  'name': _nameCtrl.text.trim(),
                                                  'clientType': _clientType,
                                                  'sex': _sex,
                                                  'date': _dateCtrl.text,
                                                  'age': _ageCtrl.text,
                                                  'region':
                                                      _regionCtrl.text.trim(),
                                                  'service':
                                                      _serviceCtrl.text.trim(),
                                                };
                                                // Pass custom questions if available
                                                if (widget.customQuestions != null) {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (_) => DynamicCC1Page(
                                                              formData: data,
                                                              questions: widget.customQuestions!,
                                                              surveyData: widget.surveyData)));
                                                } else {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (_) => CC1Page(
                                                              formData: data)));
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF8B7FE8),
                                                  elevation: 2,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8))),
                                              child: Text('Next',
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                      fontSize: 15)),
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Thank you!',
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('Your response has been recorded.',
                  style: GoogleFonts.poppins(fontSize: 14)),
              const SizedBox(height: 20),
              SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A84FF)),
                  child: Text('Done',
                      style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
