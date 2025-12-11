import 'package:flutter/material.dart';
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
  bool _loading = true;
  bool _showLandingPage = true;
  bool _showSQDPage = false;
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _regionController = TextEditingController();
  final _serviceController = TextEditingController();
  final _suggestionsController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadSurvey();
  }

  Future<void> _loadSurvey() async {
    try {
      // First try to find survey by survey_id
      final surveyResponse = await Supabase.instance.client
          .from('surveys')
          .select('title, user_created_by, department_id')
          .eq('survey_id', widget.surveyId)
          .maybeSingle();
      
      if (surveyResponse != null) {
        // Load default ARTA questions
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
          _survey = {
            'title': surveyResponse['title'],
            'template': {'questions': _questions},
          };
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_survey == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Survey not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _showLandingPage ? _buildLandingPage() : (_showSQDPage ? _buildSQDPage() : SingleChildScrollView(
        child: Row(
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
                      'The Anti-Red Tape Authority (ARTA) is a government agency in the Philippines established to streamline public service processes and eliminate bureaucratic inefficiencies. Its main goal is to ensure faster, more transparent, and citizen-friendly government services by implementing the provisions of the Anti-Red Tape Act (RA 11032). ARTA monitors compliance, addresses complaints, and promotes reforms to reduce delays and improve government accountability.',
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
                        'INSTRUCTIONS: Please place a Check mark (✓) in the designated box that corresponds to your answer. Check mark (✔) your answer to the Citizen\'s Charter (CC) questions. The Citizen\'s Charter is an official document that reflects the services of a government agency/office including its requirements, fees, and processing times among others.',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ..._questions.where((q) => q['code'].toString().startsWith('CC')).map((q) => _buildQuestionDark(q)),
                    const SizedBox(height: 32),
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
                              setState(() => _showSQDPage = true);
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
      )),
    );
  }

  Widget _buildLandingPage() {
    return Row(
      children: [
        Container(
          width: 550,
          color: Colors.white,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/city_logo.png', width: 50, height: 50, errorBuilder: (_, __, ___) => const Icon(Icons.location_city, size: 50)),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CITY GOVERNMENT OF VALENZUELA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('HELP US SERVE YOU BETTER!', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'TERMS AND CONDITIONS',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'By continuing to access and accomplish this Customer Satisfaction Survey, you hereby acknowledge and agree to the following terms and conditions:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Purpose of Data Collection',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'I understand that the information I provide shall be utilized exclusively for the evaluation, monitoring, and continuous improvement of the services rendered by the City Government of Valenzuela. All collected data will support the City\'s efforts to enhance service quality and uphold ARTA-compliant standards.',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Data Privacy and Confidentiality',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'I acknowledge that the City Government of Valenzuela is fully committed to protecting my personal information in compliance with the Data Privacy Act of 2012 and its implementing rules and regulations. All personal data collected through this survey will be treated with strict confidentiality and will not be disclosed to unauthorized individuals or entities.',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Rights of the Data Subject',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'I understand that, as a data subject, I am entitled to the following rights under the Data Privacy Act: The right to be informed regarding the collection, processing, and purpose of my personal data; The right to access my personal information and request corrections for any inaccuracies; The right to object to the processing of my personal data, subject to applicable laws and regulations; The right to lodge a complaint with the National Privacy Commission for any concerns relating to the handling of my personal data.',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Voluntary Participation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'I acknowledge that my participation in this survey is entirely voluntary and that I may discontinue or decline to proceed at any time without penalty.',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.blue[50],
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _answers['consent_agreed'] == true,
                        onChanged: (value) => setState(() => _answers['consent_agreed'] = value),
                      ),
                      const Expanded(
                        child: Text(
                          'I confirm that I have carefully read, understood, and voluntarily consent to the provisions stated above.',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _answers['consent_agreed'] == true
                        ? () => setState(() => _showLandingPage = false)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _answers['consent_agreed'] == true ? Colors.blue : Colors.grey,
                    ),
                    child: const Text('Take Survey', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.5),
              padding: const EdgeInsets.all(64),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
                      children: [
                        const TextSpan(text: 'Anti'),
                        TextSpan(text: 'Red Tape', style: TextStyle(color: Colors.red[700])),
                        const TextSpan(text: ' Authority'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'This Client Satisfaction Measurement (CSM) tracks the customer experience of government offices. Your feedback on your recently concluded transaction will help this office provide a better service. Personal information shared will be kept confidential and you always have the option to not answer this form.',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 56),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      children: [
                        const TextSpan(text: 'Purpose of Anti'),
                        TextSpan(text: 'Red Tape', style: TextStyle(color: Colors.red[700])),
                        const TextSpan(text: ' Authority'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'The purpose of the Anti-Red Tape Authority (ARTA) is to streamline government processes, reduce bureaucratic delays, and ensure efficient, transparent, and citizen-friendly public services. It monitors compliance with the Anti-Red Tape Act (RA 11032), addresses complaints, and promotes reforms to improve accountability and service delivery across government agencies.',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSQDPage() {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(32),
        child: Column(
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
          const Text('For SQD 0-8. Please select the best that corresponds to your answer.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ..._questions.where((q) => q['code'].toString().startsWith('SQD')).map((q) => _buildSQDQuestion(q)),
          const SizedBox(height: 24),
          _buildSuggestionsSection(),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: _submitSurvey,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
              child: const Text('SUBMIT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          ],
        ),
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
            decoration: const InputDecoration(border: InputBorder.none, isDense: true),
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
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _selectedDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate != null 
                                ? '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}'
                                : 'Select Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: _selectedDate != null ? Colors.black : Colors.grey[600],
                            ),
                          ),
                          Icon(Icons.calendar_today, size: 16, color: Colors.blue[600]),
                        ],
                      ),
                    ),
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

  Widget _buildSQDQuestion(Map<String, dynamic> question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red[700],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              question['code'],
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              question['text'],
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 16),
          ...List.generate(5, (index) {
            final value = 5 - index;
            return _buildCircleButton(question['code'], value);
          }),
          _buildCircleButton(question['code'], 0, isNA: true),
        ],
      ),
    );
  }

  Widget _buildCircleButton(String code, int value, {bool isNA = false}) {
    final isSelected = _answers[code] == value;
    Color color;
    String emoji;
    String label;
    
    if (isNA) {
      color = Colors.grey;
      emoji = '😐';
      label = 'N/A';
    } else if (value == 5) {
      color = Colors.green;
      emoji = '😊';
      label = 'Strongly Agree';
    } else if (value == 4) {
      color = Colors.lightGreen;
      emoji = '🙂';
      label = 'Agree';
    } else if (value == 3) {
      color = Colors.yellow;
      emoji = '😐';
      label = 'Neutral';
    } else if (value == 2) {
      color = Colors.orange;
      emoji = '☹️';
      label = 'Disagree';
    } else {
      color = Colors.red;
      emoji = '😞';
      label = 'Strongly Disagree';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => setState(() => _answers[code] = value),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 9),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.white,
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(Map<String, dynamic> question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${question['code']}: ${question['text']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            question['type'] == 'multiple_choice'
                ? _buildCheckboxOptions(question['code'], question['options'])
                : question['type'] == 'satisfaction'
                    ? _buildSatisfactionRating(question['code'])
                    : _buildAgreeDisagreeRating(question['code']),
          ],
        ),
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

  Widget _buildSatisfactionRating(String code) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ratingButton(code, 5, '😊', 'Very Satisfied', Colors.green),
        _ratingButton(code, 4, '🙂', 'Satisfied', Colors.lightGreen),
        _ratingButton(code, 3, '😐', 'Neutral', Colors.orange),
        _ratingButton(code, 2, '☹️', 'Dissatisfied', Colors.deepOrange),
        _ratingButton(code, 1, '😞', 'Very Dissatisfied', Colors.red),
      ],
    );
  }

  Widget _buildAgreeDisagreeRating(String code) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ratingButton(code, 1, '1', 'Strongly\nDisagree', Colors.red),
        _ratingButton(code, 2, '2', 'Disagree', Colors.deepOrange),
        _ratingButton(code, 3, '3', 'Neither Agree\nnor Disagree', Colors.orange),
        _ratingButton(code, 4, '4', 'Agree', Colors.lightGreen),
        _ratingButton(code, 5, '5', 'Strongly\nAgree', Colors.green),
        _ratingButton(code, 0, 'N/A', 'Not\nApplicable', Colors.grey),
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
                Text(emoji, style: const TextStyle(fontSize: 24)),
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

  Widget _buildSuggestionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Suggestions on how we can further improve our services (optional):', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            TextFormField(controller: _suggestionsController, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email address (optional)', border: OutlineInputBorder())),
          ],
        ),
      ),
    );
  }

  void _submitSurvey() async {
    if (_answers['client_type'] == null || _answers['sex'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required client information')),
      );
      return;
    }

    try {
      print('Starting survey submission...');
      final respondentId = const Uuid().v4();
      final responseId = const Uuid().v4();
      
      // Get the survey info to determine the correct department
      final surveyInfo = await Supabase.instance.client
          .from('surveys')
          .select('user_created_by, department_id')
          .eq('survey_id', widget.surveyId)
          .single();
      
      final surveyUserId = surveyInfo['user_created_by'];
      final departmentId = surveyInfo['department_id'];
      print('Using department: $departmentId');

      // Insert respondent
      print('Inserting respondent...');
      await Supabase.instance.client.from('respondents').insert({
        'respondent_id': respondentId,
        'client_type': _answers['client_type'],
        'name': _nameController.text.isEmpty ? null : _nameController.text,
        'age': int.tryParse(_ageController.text ?? ''),
        'sex': _answers['sex'],
        'region_of_residence': _regionController.text.isEmpty ? null : _regionController.text,
      });

      // Survey already exists, no need to upsert
      
      final surveyId = widget.surveyId;
      print('Using survey ID: $surveyId');

      // Create or get service record
      String? serviceId;
      if (_serviceController.text.isNotEmpty) {
        print('Creating service record...');
        serviceId = const Uuid().v4();
        await Supabase.instance.client.from('services').insert({
          'service_id': serviceId,
          'service_name': _serviceController.text,
          'department_id': departmentId,
        });
      }

      // Insert response
      print('Inserting response...');
      await Supabase.instance.client.from('responses').insert({
        'response_id': responseId,
        'survey_id': surveyId,
        'respondent_id': respondentId,
        'service_availed_id': serviceId,
      }).select();

      // Create questions and insert response answers
      print('Processing ${_questions.length} questions...');
      for (var question in _questions) {
        final questionCode = question['code'];
        if (_answers.containsKey(questionCode)) {
          print('Processing question: $questionCode');
          
          // Check if question exists
          var existingQuestion = await Supabase.instance.client
              .from('questions')
              .select()
              .eq('survey_id', surveyId)
              .eq('question_code', questionCode)
              .maybeSingle();

          String questionId;
          if (existingQuestion == null) {
            questionId = const Uuid().v4();
            await Supabase.instance.client.from('questions').insert({
              'question_id': questionId,
              'survey_id': surveyId,
              'question_code': questionCode,
              'question_text': question['text'],
              'question_type': question['type'],
            });
          } else {
            questionId = existingQuestion['question_id'];
          }

          // Insert answer
          final answer = _answers[questionCode];
          String? textAnswer;
          int? ratingValue;
          
          if (question['type'] == 'multiple_choice') {
            // For CC questions, store the actual option text
            final options = question['options'] as List<dynamic>?;
            if (options != null && answer is int && answer > 0 && answer <= options.length) {
              textAnswer = options[answer - 1].toString();
            }
            ratingValue = null;
          } else {
            // For SQD questions, store as rating value
            textAnswer = null;
            ratingValue = answer is int ? answer : null;
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
        print('Inserting suggestions...');
        await Supabase.instance.client.from('suggestions').insert({
          'suggestion_id': const Uuid().v4(),
          'response_id': responseId,
          'comment_text': _suggestionsController.text.isEmpty ? null : _suggestionsController.text,
          'email_optional': _emailController.text.isEmpty ? null : _emailController.text,
        });
      }

      print('Survey submitted successfully!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Survey submitted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Survey submission error: $e');
      String errorMsg = 'Submission failed';
      if (e.toString().contains('foreign key')) {
        errorMsg = 'Survey not found in database';
      } else if (e.toString().contains('duplicate')) {
        errorMsg = 'Response already exists';
      } else {
        errorMsg = 'Error: $e';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), duration: const Duration(seconds: 5)),
      );
    }
  }
}
