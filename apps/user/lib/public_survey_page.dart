import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class PublicSurveyPage extends StatefulWidget {
  final String surveyId;
  const PublicSurveyPage({super.key, required this.surveyId});

  @override
  State<PublicSurveyPage> createState() => _PublicSurveyPageState();
}

class _PublicSurveyPageState extends State<PublicSurveyPage> {
  Map<String, dynamic>? _survey;
  List<Map<String, dynamic>> _questions = [];
  final Map<String, dynamic> _answers = {};
  final Map<String, dynamic> _formData = {};
  bool _loading = true;
  bool _showLandingPage = true;
  bool _showSurveyForm = false;
  int _currentQuestionIndex = 0;
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _regionController = TextEditingController();
  final _serviceController = TextEditingController();
  final _suggestionsController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSurvey();
  }

  Future<void> _loadSurvey() async {
    try {
      print('Loading survey with ID: ${widget.surveyId}');
      final surveyIdInt = int.tryParse(widget.surveyId);
      if (surveyIdInt == null) {
        print('Invalid survey ID format: ${widget.surveyId}');
        _setDefaultQuestions();
        return;
      }
      
      final response = await Supabase.instance.client
          .from('survey_templates')
          .select()
          .eq('id', surveyIdInt)
          .maybeSingle();
      
      if (response == null) {
        print('Survey not found with ID: $surveyIdInt, using default questions');
        _setDefaultQuestions();
        return;
      }
      
      final template = response['template'] as Map<String, dynamic>?;
      if (template != null && template['questions'] != null) {
        _questions = List<Map<String, dynamic>>.from(template['questions']);
      } else {
        _setDefaultQuestions();
      }
      
      setState(() {
        _survey = response;
        _loading = false;
      });
    } catch (e) {
      print('Error loading survey: $e');
      _setDefaultQuestions();
    }
  }

  void _setDefaultQuestions() {
    _questions = [
      {'code': 'CC1', 'text': 'Which of the following best describes your awareness of a CC?', 'type': 'multiple_choice', 'options': ['I know what a CC is and I saw this office\'s CC', 'I know what a CC is but I did NOT see this office\'s CC', 'I learned of the CC only when I saw this office\'s CC', 'I do not know what a CC is']},
      {'code': 'CC2', 'text': 'If aware of CC (answered 1-3 in CC1), would you say that the CC of this office was...?', 'type': 'multiple_choice', 'options': ['Easy to see', 'Somewhat easy to see', 'Difficult to see', 'Not visible at all', 'N/A']},
      {'code': 'CC3', 'text': 'If aware of CC (answered codes 1-3 in CC1), how much did the CC help you in your transaction?', 'type': 'multiple_choice', 'options': ['Helped very much', 'Somewhat helped', 'Did not help', 'N/A']},
      {'code': 'SQD0', 'text': 'I am satisfied with the service that I availed', 'type': 'satisfaction'},
      {'code': 'SQD1', 'text': 'I spent a reasonable amount of time for my transaction', 'type': 'rating'},
      {'code': 'SQD2', 'text': 'The office followed the transaction\'s requirements and steps based on the information provided', 'type': 'rating'},
      {'code': 'SQD3', 'text': 'The steps (including payment) I needed to do for my transaction were easy and simple', 'type': 'rating'},
      {'code': 'SQD4', 'text': 'I easily found information about my transaction from the office or its website', 'type': 'rating'},
      {'code': 'SQD5', 'text': 'I paid a reasonable amount of fees for my transaction', 'type': 'rating'},
      {'code': 'SQD6', 'text': 'I feel the office was fair to everyone, or "walang palakasan"', 'type': 'rating'},
      {'code': 'SQD7', 'text': 'I was treated courteously by the staff, and (if asked for help) the staff was helpful', 'type': 'rating'},
      {'code': 'SQD8', 'text': 'I got what I needed from the government office, or (if denied) denial of request was sufficiently explained to me', 'type': 'rating'},
    ];
    setState(() {
      _survey = {'id': 0, 'title': 'ARTA Customer Satisfaction Survey'};
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Stack(
          children: [
            _buildBackground(),
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          ],
        ),
      );
    }

    if (_survey == null && _questions.isEmpty) {
      return Scaffold(
        body: Stack(
          children: [
            _buildBackground(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'Survey not found',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_showLandingPage) {
      return _buildLandingPage();
    } else if (_showSurveyForm) {
      return _buildSurveyForm();
    } else {
      return _buildClientInfoPage();
    }
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/background.jpeg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) =>
                Container(color: Colors.grey.shade800),
          ),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.55)),
        ),
      ],
    );
  }

  Widget _buildLandingPage() {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
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
                          if (_survey != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                _survey!['title'] ?? 'Custom Survey',
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 18),
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(Radius.circular(12))),
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
                                                  '${_questions.length} questions',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: Colors.blue.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 44,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                setState(() => _showLandingPage = false);
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

  Widget _buildClientInfoPage() {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/city_logo.png', width: 50, height: 50, errorBuilder: (_, __, ___) => const Icon(Icons.location_city, size: 50)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CITY GOVERNMENT OF VALENZUELA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('HELP US SERVE YOU BETTER!', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'This Client Satisfaction Measurement (CSM) tracks the customer experience of government offices. Your feedback on your recently concluded transaction will help this office provide a better service. Personal information shared will be kept confidential and you always have the option to not answer this form.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  _buildClientInfoSection(),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: const Color(0xFF2C3E50),
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'INSTRUCTIONS: Please place a Check mark (✓) in the designated box that corresponds to your answer on the Citizen\'s Charter (CC) questions. For any suggestions or complaints, please log-on to https://arta.gov.ph/, click RIA Portal Services and fill out the form that reflects the services of a government agency/office rendering a merchandise.',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ..._questions.where((q) => q['code'].toString().startsWith('CC')).map((q) => _buildQuestionDark(q)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_answers['client_type'] == null || _answers['sex'] == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please fill in required client information')),
                              );
                              return;
                            }
                            setState(() => _showSurveyForm = true);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600]),
                          child: const Text('Next Page'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionDark(Map<String, dynamic> question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              question['code'],
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question['text'],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          _buildCheckboxOptions(question['code'], question['options']),
        ],
      ),
    );
  }

  Widget _buildCheckboxOptions(String code, List<dynamic>? options) {
    return Column(
      children: (options ?? []).asMap().entries.map((entry) {
        final index = entry.key + 1;
        final option = entry.value;
        return CheckboxListTile(
          title: Text('$index. $option'),
          value: _answers[code] == index,
          onChanged: (checked) => setState(() => _answers[code] = checked == true ? index : null),
          controlAffinity: ListTileControlAffinity.leading,
        );
      }).toList(),
    );
  }

  Widget _buildSurveyForm() {
    final size = MediaQuery.of(context).size;
    final question = _questions[_currentQuestionIndex];
    final questionCode = question['code'];
    final isLastQuestion = _currentQuestionIndex >= _questions.length - 1;
    
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.height * 0.02,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: size.width < 420
                                ? size.width * 0.92
                                : 400,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                child: LinearProgressIndicator(
                                  value: (_currentQuestionIndex + 1) / _questions.length,
                                  backgroundColor: Colors.white30,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _buildQuestionWidget(question),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              if (_currentQuestionIndex > 0) {
                                                setState(() => _currentQuestionIndex--);
                                              } else {
                                                setState(() => _showSurveyForm = false);
                                              }
                                            },
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 12,
                                              ),
                                            ),
                                            child: Text(
                                              'Previous',
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF8B7FE8),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: _answers[questionCode] != null 
                                              ? () {
                                                  if (isLastQuestion) {
                                                    _showFeedbackDialog();
                                                  } else {
                                                    setState(() => _currentQuestionIndex++);
                                                  }
                                                }
                                              : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isLastQuestion 
                                                ? const Color(0xFF00C853)
                                                : const Color(0xFF8B7FE8),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 32,
                                                vertical: 12,
                                              ),
                                              elevation: 2,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Text(
                                              isLastQuestion ? 'Submit' : 'Next',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
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

  Widget _buildClientInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: 'Optional'),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Client Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(width: 24),
            Checkbox(value: _answers['client_type'] == 'Citizen', onChanged: (v) => setState(() => _answers['client_type'] = v == true ? 'Citizen' : null)),
            const Text('Citizen', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 16),
            Checkbox(value: _answers['client_type'] == 'Business', onChanged: (v) => setState(() => _answers['client_type'] = v == true ? 'Business' : null)),
            const Text('Business', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 16),
            Checkbox(value: _answers['client_type'] == 'Government', onChanged: (v) => setState(() => _answers['client_type'] = v == true ? 'Government' : null)),
            const Text('Government', style: TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Sex', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(width: 24),
            Checkbox(value: _answers['sex'] == 'Male', onChanged: (v) => setState(() => _answers['sex'] = v == true ? 'Male' : null)),
            const Text('Male', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 16),
            Checkbox(value: _answers['sex'] == 'Female', onChanged: (v) => setState(() => _answers['sex'] = v == true ? 'Female' : null)),
            const Text('Female', style: TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    height: 40,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Age', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Region of residence', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: TextFormField(
            controller: _regionController,
            decoration: const InputDecoration(border: InputBorder.none, isDense: true),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Service Availed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: TextFormField(
            controller: _serviceController,
            decoration: const InputDecoration(border: InputBorder.none, isDense: true),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionWidget(Map<String, dynamic> question) {
    final questionCode = question['code'];
    
    switch (question['type']) {
      case 'multiple_choice':
        return _buildMultipleChoice(questionCode, question);
      case 'satisfaction':
        return _buildSatisfactionRating(questionCode, question);
      case 'rating':
        return _buildRating(questionCode, question);
      default:
        return _buildRating(questionCode, question);
    }
  }

  Widget _buildMultipleChoice(String code, Map<String, dynamic> question) {
    final options = List<String>.from(question['options'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            code,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          question['text'],
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        ...options.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final option = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: () => setState(() => _answers[code] = option),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.scale(
                      scale: 1.1,
                      child: Radio<String>(
                        value: option,
                        groupValue: _answers[code],
                        onChanged: (v) => setState(() => _answers[code] = v),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          '$index. $option',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSatisfactionRating(String code, Map<String, dynamic> question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            code,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          question['text'],
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(60),
            ),
            child: Center(
              child: Text(
                _getEmojiForRating(_answers[code]),
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._getSatisfactionOptions().map((option) => Padding(
          padding: const EdgeInsets.only(bottom: 2.0),
          child: InkWell(
            onTap: () => setState(() => _answers[code] = option),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: _answers[code] == option ? const Color(0xFFE8F0FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Transform.scale(
                    scale: 1.1,
                    child: Radio<String>(
                      value: option,
                      groupValue: _answers[code],
                      onChanged: (v) => setState(() => _answers[code] = v),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      option,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: _answers[code] == option ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildRating(String code, Map<String, dynamic> question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            code,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          question['text'],
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ratingButton(code, 1, '😞', 'Strongly\nDisagree', Colors.red),
            _ratingButton(code, 2, '☹️', 'Disagree', Colors.deepOrange),
            _ratingButton(code, 3, '😐', 'Neither Agree\nnor Disagree', Colors.orange),
            _ratingButton(code, 4, '🙂', 'Agree', Colors.lightGreen),
            _ratingButton(code, 5, '😊', 'Strongly\nAgree', Colors.green),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: _ratingButton(code, 0, '', 'Not\nApplicable', Colors.grey),
        ),
      ],
    );
  }

  Widget _ratingButton(String code, int value, String emoji, String label, Color color) {
    final isSelected = _answers[code] == value;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: () => setState(() => _answers[code] = value),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.2) : Colors.grey[100],
              border: Border.all(color: isSelected ? color : Colors.grey[300]!, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                if (emoji.isNotEmpty) Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? color : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _getSatisfactionOptions() {
    return [
      'Very Satisfied',
      'Satisfied',
      'Neither Satisfied nor Dissatisfied',
      'Dissatisfied',
      'Very Dissatisfied',
    ];
  }

  String _getEmojiForRating(dynamic rating) {
    if (rating == null) return '😐';
    switch (rating) {
      case 'Very Satisfied': return '😊';
      case 'Satisfied': return '🙂';
      case 'Neither Satisfied nor Dissatisfied': return '😐';
      case 'Dissatisfied': return '☹️';
      case 'Very Dissatisfied': return '😞';
      default: return '😐';
    }
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Additional Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _suggestionsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Suggestions (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submitSurvey();
            },
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitSurvey();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _submitSurvey() async {
    try {
      final respondentId = const Uuid().v4();
      final responseId = const Uuid().v4();
      final surveyId = const Uuid().v4();
      
      // Insert respondent
      await Supabase.instance.client.from('respondents').insert({
        'respondent_id': respondentId,
        'client_type': _answers['client_type'],
        'name': _nameController.text,
        'age': int.tryParse(_ageController.text),
        'sex': _answers['sex'],
        'region_of_residence': _regionController.text,
      });
      
      // Create survey
      await Supabase.instance.client.from('surveys').insert({
        'survey_id': surveyId,
        'title': _survey?['title'] ?? 'ARTA Survey',
        'user_created_by': const Uuid().v4(), // Mock user ID
      });
      
      // Create service if provided
      String? serviceId;
      if (_serviceController.text.isNotEmpty) {
        serviceId = const Uuid().v4();
        await Supabase.instance.client.from('services').insert({
          'service_id': serviceId,
          'service_name': _serviceController.text,
          'department_id': const Uuid().v4(), // Mock department ID
        });
      }
      
      // Insert response
      await Supabase.instance.client.from('responses').insert({
        'response_id': responseId,
        'survey_id': surveyId,
        'respondent_id': respondentId,
        'service_availed_id': serviceId,
      });
      
      // Insert questions and answers
      for (var question in _questions) {
        final questionCode = question['code'];
        if (_answers.containsKey(questionCode)) {
          final questionId = const Uuid().v4();
          
          // Insert question
          await Supabase.instance.client.from('questions').insert({
            'question_id': questionId,
            'survey_id': surveyId,
            'question_code': questionCode,
            'question_text': question['text'],
            'question_type': question['type'],
          });
          
          // Insert answer
          final answer = _answers[questionCode];
          int? ratingValue;
          String? textAnswer;
          
          if (answer is int) {
            ratingValue = answer;
          } else if (answer is String) {
            // Convert satisfaction text to numeric rating
            switch (answer) {
              case 'Very Satisfied': ratingValue = 5; break;
              case 'Satisfied': ratingValue = 4; break;
              case 'Neither Satisfied nor Dissatisfied': ratingValue = 3; break;
              case 'Dissatisfied': ratingValue = 2; break;
              case 'Very Dissatisfied': ratingValue = 1; break;
              default: textAnswer = answer;
            }
          }
          
          await Supabase.instance.client.from('response_answers').insert({
            'answer_id': const Uuid().v4(),
            'response_id': responseId,
            'question_id': questionId,
            'rating_value': ratingValue,
            'text_answer': textAnswer,
          });
        }
      }
      
      // Insert suggestions if provided
      if (_suggestionsController.text.isNotEmpty || _emailController.text.isNotEmpty) {
        await Supabase.instance.client.from('suggestions').insert({
          'suggestion_id': const Uuid().v4(),
          'response_id': responseId,
          'comment_text': _suggestionsController.text,
          'email_optional': _emailController.text,
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Survey submitted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}