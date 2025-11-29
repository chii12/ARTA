import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'admin_scaffold.dart';
import 'survey_editor_page.dart';

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

  Future<void> _deleteSurvey(String surveyId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Survey'),
        content: const Text('Are you sure you want to delete this survey?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Supabase.instance.client
            .from('surveys')
            .delete()
            .eq('survey_id', surveyId);
        _loadSurveys();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Survey deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _createSurveyOld(Map<String, dynamic> template) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Get the actual logged-in user's data
      final userResponse = await Supabase.instance.client
          .from('users')
          .select('user_id, department_id')
          .eq('email', user.email!)
          .single();
      
      final userData = {
        'user_id': userResponse['user_id'],
        'department_id': userResponse['department_id']
      };

      // Generate UUID for survey
      final surveyId = const Uuid().v4();
      
      // Create survey record
      await Supabase.instance.client.from('surveys').insert({
        'survey_id': surveyId,
        'title': template['title'],
        'user_created_by': userData['user_id'],
        'department_id': userData['department_id'],
        'qr_code_url': 'https://yourapp.com/survey/$surveyId',
      });

      // Create questions from template
      final templateData = template['template'] as Map<String, dynamic>;
      final questions = templateData['questions'] as List<dynamic>;
      
      for (var question in questions) {
        await Supabase.instance.client.from('questions').insert({
          'question_id': const Uuid().v4(),
          'survey_id': surveyId,
          'question_code': question['code'],
          'question_text': question['text'],
          'question_type': question['type'],
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Survey created successfully! Go to QR Code page to generate QR.')),
      );
      _loadSurveys(); // Reload the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating survey: $e')),
      );
    }
  }

  Future<void> _deleteTemplateOld(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: const Text('Are you sure you want to delete this template?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Supabase.instance.client
            .from('survey_templates')
            .delete()
            .eq('id', id);
        _loadSurveys();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Template deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _loadSurveys() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() => _loading = false);
        return;
      }
      
      // Get user's department to filter templates
      final userResponse = await Supabase.instance.client
          .from('users')
          .select('user_id, department_id')
          .eq('email', user.email!)
          .maybeSingle();
      
      if (userResponse == null) {
        setState(() {
          _surveys = [];
          _loading = false;
        });
        return;
      }
      
      // Load actual surveys for this department
      final response = await Supabase.instance.client
          .from('surveys')
          .select('*')
          .eq('department_id', userResponse['department_id'])
          .order('survey_date', ascending: false);
      
      setState(() {
        _surveys = List<Map<String, dynamic>>.from(response);
        _loading = false;
      });
    } catch (e) {
      print('Survey page error: $e');
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading templates: $e')),
        );
      }
    }
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Survey Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const SurveyEditorPage()));
                      if (result == true) {
                        _loadSurveys();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Survey'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _surveys.isEmpty
                      ? const Center(child: Text('No surveys found'))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _surveys.length,
                            itemBuilder: (context, index) {
                              final survey = _surveys[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(survey['title'] ?? 'Untitled Survey'),
                                  subtitle: Text('Created: ${survey['survey_date']?.toString().split('T')[0] ?? 'Unknown'}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                    onPressed: () => _deleteSurvey(survey['survey_id']),
                                  ),
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

class ARTASurveyForm extends StatefulWidget {
  final Map<String, dynamic> survey;
  const ARTASurveyForm({super.key, required this.survey});

  @override
  State<ARTASurveyForm> createState() => _ARTASurveyFormState();
}

class _ARTASurveyFormState extends State<ARTASurveyForm> {
  final Map<String, dynamic> _answers = {};
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _artaQuestions = [];
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _regionController = TextEditingController();
  final _serviceController = TextEditingController();
  final _suggestionsController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    final template = widget.survey['template'] as Map<String, dynamic>?;
    if (template != null && template['questions'] != null) {
      _artaQuestions = List<Map<String, dynamic>>.from(template['questions']);
      // Ensure CC questions are checkbox type
      for (var q in _artaQuestions) {
        if (q['code'].toString().startsWith('CC') && q['type'] != 'multiple_choice') {
          q['type'] = 'multiple_choice';
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.survey['title'] ?? 'ARTA Survey'),
        backgroundColor: Colors.blue[700],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HELP US SERVE YOU BETTER!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
              const SizedBox(height: 8),
              const Text(
                'This Client Satisfaction Measurement (CSM) tracks the customer experience of government offices. Your feedback on your recently concluded transaction will help this office provide a better service. Personal information shared will be kept confidential and you always have the option to not answer this form.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildClientInfoSection(),
              const SizedBox(height: 24),
              Card(
                color: Colors.blue[50],
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INSTRUCTIONS: Check mark (✔) your answer to the Citizen\'s Charter (CC) questions.',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'The Citizen\'s Charter is an official document that reflects the services of a government agency/office including its requirements, fees, and processing times among others.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ..._artaQuestions.where((q) => q['code'].toString().startsWith('CC')).map((q) => _buildQuestion(q)),
              const SizedBox(height: 24),
              Card(
                color: Colors.blue[50],
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'INSTRUCTIONS: For SQD 0-8, please put a check mark (✔) on the column that best corresponds to your answer.',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ..._artaQuestions.where((q) => q['code'].toString().startsWith('SQD')).map((q) => _buildQuestion(q)),
              const SizedBox(height: 24),
              _buildSuggestionsSection(),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: 300,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitSurvey,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
                        child: const Text('Submit Survey', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'THANK YOU!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  Widget _buildClientInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Client Type:', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(child: RadioListTile(title: const Text('Citizen'), value: 'Citizen', groupValue: _answers['client_type'], onChanged: (v) => setState(() => _answers['client_type'] = v))),
                Expanded(child: RadioListTile(title: const Text('Business'), value: 'Business', groupValue: _answers['client_type'], onChanged: (v) => setState(() => _answers['client_type'] = v))),
                Expanded(child: RadioListTile(title: const Text('Government'), value: 'Government', groupValue: _answers['client_type'], onChanged: (v) => setState(() => _answers['client_type'] = v))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name (Optional)', border: OutlineInputBorder()))),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      const Text('Sex: '),
                      Radio(value: 'Male', groupValue: _answers['sex'], onChanged: (v) => setState(() => _answers['sex'] = v)),
                      const Text('Male'),
                      Radio(value: 'Female', groupValue: _answers['sex'], onChanged: (v) => setState(() => _answers['sex'] = v)),
                      const Text('Female'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(width: 100, child: TextFormField(controller: _ageController, decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _regionController, decoration: const InputDecoration(labelText: 'Region of Residence', border: OutlineInputBorder()))),
                const SizedBox(width: 16),
                Expanded(child: TextFormField(controller: _serviceController, decoration: const InputDecoration(labelText: 'Service Availed', border: OutlineInputBorder()))),
              ],
            ),
          ],
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
    
    final unanswered = _artaQuestions.where((q) => !_answers.containsKey(q['code'])).toList();
    if (unanswered.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions')),
      );
      return;
    }

    try {
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
