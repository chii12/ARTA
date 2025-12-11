import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_scaffold.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  List<Map<String, dynamic>> _surveys = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSurveys();
  }

  Future<void> _loadSurveys() async {
    setState(() => _loading = true);
    try {
      final response = await Supabase.instance.client
          .from('surveys')
          .select('*, departments(department_name), users(full_name)')
          .order('survey_date', ascending: false);
      
      setState(() {
        _surveys = List<Map<String, dynamic>>.from(response);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _viewSurvey(Map<String, dynamic> survey) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SurveyFormViewer(survey: survey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      selectedRoute: '/admin/survey',
      onNavigate: (route) => Navigator.of(context).pushReplacementNamed(route),
      child: Card(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Surveys', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _surveys.isEmpty
                        ? const Center(child: Text('No surveys found'))
                        : ListView.builder(
                            itemCount: _surveys.length,
                            itemBuilder: (context, index) {
                              final survey = _surveys[index];
                              final date = DateTime.parse(survey['survey_date']);
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(survey['title'] ?? 'Untitled Survey'),
                                  subtitle: Text('Department: ${survey['departments']?['department_name'] ?? 'Unknown'} • Created by: ${survey['users']?['full_name'] ?? 'Unknown'}'),
                                  trailing: Text('${date.day}/${date.month}/${date.year}'),
                                  onTap: () => _viewSurvey(survey),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SurveyFormViewer extends StatefulWidget {
  final Map<String, dynamic> survey;

  const SurveyFormViewer({super.key, required this.survey});

  @override
  State<SurveyFormViewer> createState() => _SurveyFormViewerState();
}

class _SurveyFormViewerState extends State<SurveyFormViewer> {
  List<Map<String, dynamic>> _questions = [];
  bool _loading = true;
  bool _showLandingPage = true;
  bool _showSQDPage = false;
  final Map<String, dynamic> _answers = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _loading = true);
    try {
      // Load default ARTA questions structure
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
      
      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.survey['title'] ?? 'Survey Preview'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
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
                        const Icon(Icons.location_city, size: 50),
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
                      'The Anti-Red Tape Authority (ARTA) is a government agency in the Philippines established to streamline public service processes and eliminate bureaucratic inefficiencies.',
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
                        'INSTRUCTIONS: Please place a Check mark (✓) in the designated box that corresponds to your answer.',
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
                            onPressed: () => setState(() => _showSQDPage = true),
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
          child: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TERMS AND CONDITIONS', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text('By continuing to access and accomplish this Customer Satisfaction Survey, you hereby acknowledge and agree to the following terms and conditions:', style: TextStyle(fontSize: 16)),
                SizedBox(height: 16),
                Text('This is a preview of the survey form. All interactions are disabled.', style: TextStyle(fontSize: 14, color: Colors.red)),
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
                    'This Client Satisfaction Measurement (CSM) tracks the customer experience of government offices.',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => setState(() => _showLandingPage = false),
                    child: const Text('View Survey Form'),
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
            const Text('For SQD 0-8. Please select the best that corresponds to your answer.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._questions.where((q) => q['code'].toString().startsWith('SQD')).map((q) => _buildSQDQuestion(q)),
            const SizedBox(height: 24),
            const Text('This is a preview - submission is disabled', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfoSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Client Information (Preview Only)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Text('Name: [Preview Mode]'),
        SizedBox(height: 8),
        Text('Client Type: [Preview Mode]'),
        SizedBox(height: 8),
        Text('Sex: [Preview Mode]'),
        SizedBox(height: 8),
        Text('Age: [Preview Mode]'),
        SizedBox(height: 8),
        Text('Region: [Preview Mode]'),
        SizedBox(height: 8),
        Text('Service: [Preview Mode]'),
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
              color: Colors.white,
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
    );
  }

  Widget _buildCheckboxOptions(String code, List<dynamic>? options) {
    return Column(
      children: (options ?? []).asMap().entries.map((entry) {
        final index = entry.key + 1;
        final option = entry.value;
        return CheckboxListTile(
          title: Text('$index. $option'),
          value: false,
          onChanged: null,
          controlAffinity: ListTileControlAffinity.leading,
        );
      }).toList(),
    );
  }
}