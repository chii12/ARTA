import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'admin_scaffold.dart';

class SurveyEditorPage extends StatefulWidget {
  const SurveyEditorPage({super.key});

  @override
  State<SurveyEditorPage> createState() => _SurveyEditorPageState();
}

class _SurveyEditorPageState extends State<SurveyEditorPage> {
  final _titleController = TextEditingController();
  final List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadARTATemplate();
  }

  void _loadARTATemplate() {
    _titleController.text = 'ARTA Customer Satisfaction Survey';
    _questions.addAll([
      {'code': 'CC1', 'text': 'Which of the following best describes your awareness of a CC?', 'type': 'multiple_choice', 'options': ['I know what a CC is and I saw this office\'s CC', 'I know what a CC is but I did NOT see this office\'s CC', 'I learned of the CC only when I saw this office\'s CC', 'I do not know what a CC is and I did not see one in this office']},
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
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      selectedRoute: '/admin/survey',
      onNavigate: (route) => Navigator.of(context).pushReplacementNamed(route),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('Edit Survey Template', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Survey Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Questions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    onPressed: _addQuestion,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Question'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ReorderableListView.builder(
                  itemCount: _questions.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final item = _questions.removeAt(oldIndex);
                      _questions.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final q = _questions[index];
                    return Card(
                      key: ValueKey(index),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(Icons.drag_handle),
                        title: Text('${q['code']}: ${q['text']}'),
                        subtitle: Text('Type: ${q['type']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _editQuestion(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => setState(() => _questions.removeAt(index)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveTemplate,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
                  child: const Text('Save Template', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addQuestion() {
    final codeController = TextEditingController();
    final textController = TextEditingController();
    String selectedType = 'rating';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Question'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Question Code (e.g., SQD10)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Question Text'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Question Type'),
                items: const [
                  DropdownMenuItem(value: 'rating', child: Text('Rating (1-5)')),
                  DropdownMenuItem(value: 'satisfaction', child: Text('Satisfaction (Emoji)')),
                  DropdownMenuItem(value: 'multiple_choice', child: Text('Multiple Choice')),
                ],
                onChanged: (value) => setDialogState(() => selectedType = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (codeController.text.isNotEmpty && textController.text.isNotEmpty) {
                  setState(() {
                    _questions.add({
                      'code': codeController.text,
                      'text': textController.text,
                      'type': selectedType,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _editQuestion(int index) {
    final q = _questions[index];
    final codeController = TextEditingController(text: q['code']);
    final textController = TextEditingController(text: q['text']);
    String selectedType = q['type'] ?? 'rating';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Question'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Question Code'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Question Text'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Question Type'),
                items: const [
                  DropdownMenuItem(value: 'rating', child: Text('Rating (1-5)')),
                  DropdownMenuItem(value: 'satisfaction', child: Text('Satisfaction (Emoji)')),
                  DropdownMenuItem(value: 'multiple_choice', child: Text('Multiple Choice')),
                ],
                onChanged: (value) => setDialogState(() => selectedType = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _questions[index] = {
                    'code': codeController.text,
                    'text': textController.text,
                    'type': selectedType,
                  };
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTemplate() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Get the actual logged-in user's data
      final userResponse = await Supabase.instance.client
          .from('users')
          .select('user_id, department_id')
          .eq('email', user.email!)
          .single();

      // Generate UUID for survey
      final surveyId = const Uuid().v4();
      
      // Create survey record directly
      await Supabase.instance.client.from('surveys').insert({
        'survey_id': surveyId,
        'title': _titleController.text,
        'user_created_by': userResponse['user_id'],
        'department_id': userResponse['department_id'],
        'qr_code_url': 'https://yourapp.com/survey/$surveyId',
      });

      // Create questions
      for (var question in _questions) {
        await Supabase.instance.client.from('questions').insert({
          'question_id': const Uuid().v4(),
          'survey_id': surveyId,
          'question_code': question['code'],
          'question_text': question['text'],
          'question_type': question['type'],
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Survey created successfully! Go to QR Code page to generate QR.')),
        );
        Navigator.pop(context, true);
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
