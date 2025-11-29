import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'admin_scaffold.dart';

class ResponsesPage extends StatefulWidget {
  const ResponsesPage({super.key});

  @override
  State<ResponsesPage> createState() => _ResponsesPageState();
}

class _ResponsesPageState extends State<ResponsesPage> {
  List<Map<String, dynamic>> _responses = [];
  bool _loading = true;
  String _sortBy = 'Newest';

  @override
  void initState() {
    super.initState();
    _loadResponses();
  }

  Future<void> _loadResponses() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() => _loading = false);
        return;
      }
      
      final userData = await Supabase.instance.client
          .from('users')
          .select('department_id')
          .eq('email', user.email!)
          .single();
      
      // Debug: Check all responses
      final allResponses = await Supabase.instance.client
          .from('responses')
          .select('*, surveys(department_id)')
          .order('date_submitted', ascending: false);
      print('DEBUG Responses: Found ${allResponses.length} total responses');
      for (var r in allResponses) {
        print('Response: survey_id=${r['survey_id']}, dept=${r['surveys']?['department_id']}');
      }
      
      // Get responses for surveys in same department
      final response = await Supabase.instance.client
          .from('responses')
          .select('*, respondents(*), services(service_name, department_id), surveys!inner(department_id)')
          .eq('surveys.department_id', userData['department_id'])
          .order('date_submitted', ascending: _sortBy == 'Oldest');
      
      print('Responses page: Found ${response.length} responses for department ${userData['department_id']}');
      
      setState(() {
        _responses = List<Map<String, dynamic>>.from(response);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      selectedRoute: '/admin/responses',
      onNavigate: (route) => Navigator.of(context).pushReplacementNamed(route),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Survey Responses', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Container(
                        width: 200,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search',
                            prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey[600]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _sortBy,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'Newest', child: Text('Sort by: Newest')),
                            DropdownMenuItem(value: 'Oldest', child: Text('Sort by: Oldest')),
                          ],
                          onChanged: (value) {
                            setState(() => _sortBy = value!);
                            _loadResponses();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _responses.isEmpty
                        ? const Center(child: Text('No responses yet'))
                        : Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                ),
                                child: const Row(
                                  children: [
                                    Expanded(flex: 1, child: Text('Survey ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                    Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                    Expanded(flex: 1, child: Text('Client Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                    Expanded(flex: 2, child: Text('Region of Residence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                    Expanded(flex: 2, child: Text('Service Applied', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                    Expanded(flex: 1, child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _responses.length,
                                  itemBuilder: (context, index) {
                                    final response = _responses[index];
                                    final respondent = response['respondents'];
                                    final service = response['services'];
                                    final date = DateTime.parse(response['date_submitted']);
                                    
                                    return InkWell(
                                      onTap: () => _viewResponse(response),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(flex: 1, child: Text('00-${(index + 1).toString().padLeft(4, '0')}', style: const TextStyle(fontSize: 13))),
                                            Expanded(flex: 2, child: Text(respondent?['name'] ?? '-', style: const TextStyle(fontSize: 13))),
                                            Expanded(flex: 1, child: Text(respondent?['client_type'] ?? '-', style: const TextStyle(fontSize: 13))),
                                            Expanded(flex: 2, child: Text(respondent?['region_of_residence'] ?? '-', style: const TextStyle(fontSize: 13))),
                                            Expanded(flex: 2, child: Text(service?['service_name'] ?? '-', style: const TextStyle(fontSize: 13))),
                                            Expanded(flex: 1, child: Text('${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}-${date.year}', style: const TextStyle(fontSize: 13))),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Showing data 1 to ${_responses.length} of ${_responses.length} entries', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                    Row(
                                      children: [
                                        IconButton(icon: const Icon(Icons.chevron_left, size: 20), onPressed: () {}),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[700],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        ),
                                        IconButton(icon: const Icon(Icons.chevron_right, size: 20), onPressed: () {}),
                                      ],
                                    ),
                                    TextButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.download, size: 18),
                                      label: const Text('Export Data'),
                                    ),
                                  ],
                                ),
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

  Future<void> _viewResponse(Map<String, dynamic> response) async {
    try {
      final responseId = response['response_id'];
      final answers = await Supabase.instance.client
          .from('response_answers')
          .select('*, questions(question_code)')
          .eq('response_id', responseId);

      final suggestions = await Supabase.instance.client
          .from('suggestions')
          .select()
          .eq('response_id', responseId)
          .maybeSingle();

      final respondent = response['respondents'];
      final service = response['services'];
      final date = DateTime.parse(response['date_submitted']);
      final answersMap = <String, dynamic>{};
      for (var a in List<Map<String, dynamic>>.from(answers)) {
        final code = a['questions']?['question_code'];
        if (code != null) {
          answersMap[code] = a['rating_value'] ?? a['text_answer'];
        }
      }

      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            width: 900,
            height: 700,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Survey Response Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _printResponse(respondent, service, date, answersMap, suggestions),
                            icon: const Icon(Icons.print, size: 18),
                            label: const Text('Print'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _downloadResponse(respondent, service, date, answersMap, suggestions),
                            icon: const Icon(Icons.download, size: 18),
                            label: const Text('Download'),
                          ),
                          const SizedBox(width: 8),
                          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Control No: _______', style: TextStyle(fontSize: 12)),
                                const Text('(On-Site Version)', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                              ],
                            ),
                            Column(
                              children: [
                                Image.asset('assets/city_logo.png', width: 60, height: 60, errorBuilder: (_, __, ___) => const Icon(Icons.location_city, size: 60)),
                                const Text('GOVERNMENT INSTRUMENT POLICY BOARD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                const Text('HELP US SERVE YOU BETTER!', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(border: Border.all()),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ANTI-RED TAPE AUTHORITY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                  Text('CITIZEN SATISFACTION FORM', style: TextStyle(fontSize: 9)),
                                  Text('PSA Approval No.: ARTA 2551-3', style: TextStyle(fontSize: 8)),
                                  Text('Expires: Feb 2026', style: TextStyle(fontSize: 8)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('This Client Satisfaction Measurement (CSM) tracks the customer experience of government offices. Your feedback on your recently concluded transaction will help this office provide a better service. Personal information shared will be kept confidential and you always have the option to not answer this form.', style: TextStyle(fontSize: 10)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text('Client type: ', style: TextStyle(fontSize: 11)),
                            _checkbox(respondent?['client_type'] == 'Citizen'),
                            const Text('Citizen ', style: TextStyle(fontSize: 11)),
                            _checkbox(respondent?['client_type'] == 'Business'),
                            const Text('Business ', style: TextStyle(fontSize: 11)),
                            _checkbox(respondent?['client_type'] == 'Government'),
                            const Text('Government', style: TextStyle(fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('Date: ${date.month}/${date.day}/${date.year}', style: const TextStyle(fontSize: 11)),
                            const SizedBox(width: 32),
                            const Text('Sex: ', style: TextStyle(fontSize: 11)),
                            _checkbox(respondent?['sex'] == 'Male'),
                            const Text('Male ', style: TextStyle(fontSize: 11)),
                            _checkbox(respondent?['sex'] == 'Female'),
                            const Text('Female', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 32),
                            Text('Age: ${respondent?['age'] ?? '___'}', style: const TextStyle(fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Region of residence: ${respondent?['region_of_residence'] ?? '_______________'}', style: const TextStyle(fontSize: 11)),
                        const SizedBox(height: 4),
                        Text('Service Availed: ${service?['service_name'] ?? '_______________'}', style: const TextStyle(fontSize: 11)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.grey[200],
                          child: const Text('INSTRUCTIONS: Check mark (✓) your answer to the Citizen\'s Charter (CC) questions. The Citizen\'s Charter is an official document that reflects the services of a government agency/office including its requirements, fees, and processing times among others.', style: TextStyle(fontSize: 10)),
                        ),
                        const SizedBox(height: 12),
                        _buildCCQuestion('CC1', 'Which of the following best describes your awareness of a CC?', ['I know what a CC is and I saw this office\'s CC', 'I know what a CC is but I did NOT see this office\'s CC', 'I learned of the CC only when I saw this office\'s CC', 'I do not know what a CC is'], answersMap['CC1']),
                        _buildCCQuestion('CC2', 'If aware of CC (answered 1-3 in CC1), would you say that the CC of this office was...?', ['Easy to see', 'Somewhat easy to see', 'Difficult to see', 'Not visible at all', 'N/A'], answersMap['CC2']),
                        _buildCCQuestion('CC3', 'If aware of CC (answered codes 1-3 in CC1), how much did the CC help you in your transaction?', ['Helped very much', 'Somewhat helped', 'Did not help', 'N/A'], answersMap['CC3']),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.grey[200],
                          child: const Text('INSTRUCTIONS: For SQD 0-8, please put a check mark (✓) on the column that best corresponds to your answer.', style: TextStyle(fontSize: 10)),
                        ),
                        const SizedBox(height: 12),
                        _buildSQDTable(answersMap),
                        const SizedBox(height: 16),
                        const Text('Suggestions on how we can further improve our services (optional):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(minHeight: 60),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                          child: Text(suggestions?['comment_text'] ?? '', style: const TextStyle(fontSize: 11)),
                        ),
                        const SizedBox(height: 8),
                        Text('Email address (optional): ${suggestions?['email_optional'] ?? '___________________________'}', style: const TextStyle(fontSize: 11)),
                        const SizedBox(height: 16),
                        const Center(child: Text('THANK YOU!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _checkbox(bool checked) {
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(border: Border.all(width: 1)),
      child: checked ? const Center(child: Text('✓', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))) : null,
    );
  }

  Widget _buildCCQuestion(String code, String question, List<String> options, dynamic answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$code  $question', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...options.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                _checkbox(answer == e.value || answer == '${e.key + 1}. ${e.value}'),
                Expanded(child: Text('${e.key + 1}. ${e.value}', style: const TextStyle(fontSize: 11))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSQDTable(Map<String, dynamic> answers) {
    final questions = [
      'SQD0. I am satisfied with the service that I availed.',
      'SQD1. I spent a reasonable amount of time for my transaction.',
      'SQD2. The office followed the transaction\'s requirements and steps based on the information provided.',
      'SQD3. The steps (including payment) I needed to do for my transaction were easy and simple.',
      'SQD4. I easily found information about my transaction from the office or its website.',
      'SQD5. I paid a reasonable amount of fees for my transaction.',
      'SQD6. I feel the office was fair to everyone, or "walang palakasan".',
      'SQD7. I was treated courteously by the staff, and (if asked for help) the staff was helpful.',
      'SQD8. I got what I needed from the government office, or (if denied) denial of request was sufficiently explained to me.',
    ];

    return Table(
      border: TableBorder.all(color: Colors.black, width: 0.5),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FixedColumnWidth(50),
        2: FixedColumnWidth(50),
        3: FixedColumnWidth(50),
        4: FixedColumnWidth(50),
        5: FixedColumnWidth(50),
        6: FixedColumnWidth(50),
      },
      children: [
        TableRow(
          children: [
            const Padding(padding: EdgeInsets.all(6), child: Text('')),
            ...[{'text': 'Strongly\nDisagree', 'emoji': '😞'}, {'text': 'Disagree', 'emoji': '☹️'}, {'text': 'Neither\nAgree nor\nDisagree', 'emoji': '😐'}, {'text': 'Agree', 'emoji': '🙂'}, {'text': 'Strongly\nAgree', 'emoji': '😊'}, {'text': 'N/A', 'emoji': ''}].map((h) => Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                children: [
                  if (h['emoji']!.isNotEmpty) Text(h['emoji']!, style: const TextStyle(fontSize: 16)),
                  Text(h['text']!, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ],
              ),
            )),
          ],
        ),
        ...questions.asMap().entries.map((e) {
          final code = 'SQD${e.key}';
          final answer = answers[code];
          print('DEBUG: $code answer = $answer (${answer.runtimeType})');
          return TableRow(
            children: [
              Padding(padding: const EdgeInsets.all(6), child: Text(e.value, style: const TextStyle(fontSize: 11))),
              ...List.generate(6, (i) {
                bool isChecked = false;
                if (i == 5) {
                  // N/A column
                  isChecked = answer == 'N/A' || answer == 'Not Applicable' || answer == 0 || answer == '0';
                } else {
                  // Rating columns (1-5, but displayed as 5-1)
                  final ratingValue = 5 - i;
                  isChecked = _matchesRating(answer, ratingValue);
                }
                return Center(child: Padding(padding: const EdgeInsets.all(4), child: _checkbox(isChecked)));
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _printResponse(Map<String, dynamic>? respondent, Map<String, dynamic>? service, DateTime date, Map<String, dynamic> answersMap, Map<String, dynamic>? suggestions) async {
    final pdf = await _generatePdf(respondent, service, date, answersMap, suggestions);
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> _downloadResponse(Map<String, dynamic>? respondent, Map<String, dynamic>? service, DateTime date, Map<String, dynamic> answersMap, Map<String, dynamic>? suggestions) async {
    final pdf = await _generatePdf(respondent, service, date, answersMap, suggestions);
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'survey_response_${respondent?['name']?.replaceAll(' ', '_')}_${date.year}${date.month}${date.day}.pdf');
  }

  Future<pw.Document> _generatePdf(Map<String, dynamic>? respondent, Map<String, dynamic>? service, DateTime date, Map<String, dynamic> answersMap, Map<String, dynamic>? suggestions) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Control No: _______', style: const pw.TextStyle(fontSize: 10)),
                pw.Column(
                  children: [
                    pw.Text('GOVERNMENT INSTRUMENT POLICY BOARD', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.Text('HELP US SERVE YOU BETTER!', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  decoration: pw.BoxDecoration(border: pw.Border.all()),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('ANTI-RED TAPE AUTHORITY', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text('CITIZEN SATISFACTION FORM', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Text('This Client Satisfaction Measurement (CSM) tracks the customer experience of government offices.', style: const pw.TextStyle(fontSize: 9)),
            pw.SizedBox(height: 12),
            pw.Row(
              children: [
                pw.Text('Client type: ', style: const pw.TextStyle(fontSize: 10)),
                _pdfCheckbox(respondent?['client_type'] == 'Citizen'),
                pw.Text('Citizen ', style: const pw.TextStyle(fontSize: 10)),
                _pdfCheckbox(respondent?['client_type'] == 'Business'),
                pw.Text('Business ', style: const pw.TextStyle(fontSize: 10)),
                _pdfCheckbox(respondent?['client_type'] == 'Government'),
                pw.Text('Government', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Row(
              children: [
                pw.Text('Date: ${date.month}/${date.day}/${date.year}', style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(width: 20),
                pw.Text('Sex: ', style: const pw.TextStyle(fontSize: 10)),
                _pdfCheckbox(respondent?['sex'] == 'Male'),
                pw.Text('Male ', style: const pw.TextStyle(fontSize: 10)),
                _pdfCheckbox(respondent?['sex'] == 'Female'),
                pw.Text('Female', style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(width: 20),
                pw.Text('Age: ${respondent?['age'] ?? '___'}', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Text('Region: ${respondent?['region_of_residence'] ?? '___'}', style: const pw.TextStyle(fontSize: 10)),
            pw.Text('Service: ${service?['service_name'] ?? '___'}', style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              color: PdfColors.grey300,
              child: pw.Text('CC Questions', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 8),
            _pdfCCQuestion('CC1', 'Awareness of CC?', ['Know and saw', 'Know but did not see', 'Learned when saw', 'Do not know'], answersMap['CC1']),
            _pdfCCQuestion('CC2', 'CC visibility?', ['Easy to see', 'Somewhat easy', 'Difficult', 'Not visible', 'N/A'], answersMap['CC2']),
            _pdfCCQuestion('CC3', 'CC helpfulness?', ['Helped very much', 'Somewhat helped', 'Did not help', 'N/A'], answersMap['CC3']),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              color: PdfColors.grey300,
              child: pw.Text('SQD Questions (1=Strongly Disagree, 5=Strongly Agree)', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 8),
            ...List.generate(9, (i) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                children: [
                  pw.Container(width: 300, child: pw.Text('SQD$i', style: const pw.TextStyle(fontSize: 9))),
                  pw.Text('Answer: ${answersMap['SQD$i'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            )),
            pw.SizedBox(height: 12),
            pw.Text('Suggestions:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              child: pw.Text(suggestions?['comment_text'] ?? '', style: const pw.TextStyle(fontSize: 9)),
            ),
            pw.SizedBox(height: 6),
            pw.Text('Email: ${suggestions?['email_optional'] ?? '___'}', style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
    
    return pdf;
  }

  pw.Widget _pdfCheckbox(bool checked) {
    return pw.Container(
      width: 12,
      height: 12,
      margin: const pw.EdgeInsets.symmetric(horizontal: 3),
      decoration: pw.BoxDecoration(border: pw.Border.all()),
      child: checked ? pw.Center(child: pw.Text('✓', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))) : null,
    );
  }

  pw.Widget _pdfCCQuestion(String code, String question, List<String> options, dynamic answer) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$code: $question', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          ...options.asMap().entries.map((e) => pw.Row(
            children: [
              _pdfCheckbox(answer == e.value || answer == '${e.key + 1}. ${e.value}'),
              pw.Text('${e.key + 1}. ${e.value}', style: const pw.TextStyle(fontSize: 9)),
            ],
          )),
        ],
      ),
    );
  }

  bool _matchesRating(dynamic answer, int ratingValue) {
    if (answer == null) return false;
    
    final answerStr = answer.toString();
    
    // Direct numeric match
    if (answer == ratingValue || answerStr == ratingValue.toString()) return true;
    
    // All possible text matches for each rating
    switch (ratingValue) {
      case 1:
        return answerStr == 'Strongly Disagree' || 
               answerStr == 'Very Dissatisfied' ||
               answerStr.contains('😞') ||
               answerStr == '1';
      case 2:
        return answerStr == 'Disagree' || 
               answerStr == 'Dissatisfied' ||
               answerStr.contains('☹️') ||
               answerStr == '2';
      case 3:
        return answerStr == 'Neither Agree nor Disagree' || 
               answerStr == 'Neutral' ||
               answerStr.contains('😐') ||
               answerStr == '3';
      case 4:
        return answerStr == 'Agree' || 
               answerStr == 'Satisfied' ||
               answerStr.contains('🙂') ||
               answerStr == '4';
      case 5:
        return answerStr == 'Strongly Agree' || 
               answerStr == 'Very Satisfied' ||
               answerStr.contains('😊') ||
               answerStr == '5';
      default:
        return false;
    }
  }

  String _getSatisfactionText(int value) {
    switch (value) {
      case 1: return 'Strongly Disagree';
      case 2: return 'Disagree';
      case 3: return 'Neither Agree nor Disagree';
      case 4: return 'Agree';
      case 5: return 'Strongly Agree';
      default: return 'N/A';
    }
  }

  String _getEmojiText(int value) {
    switch (value) {
      case 1: return '😞';
      case 2: return '☹️';
      case 3: return '😐';
      case 4: return '🙂';
      case 5: return '😊';
      default: return '';
    }
  }
}
