import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/survey_service.dart';

class SavedSurveysPage extends StatefulWidget {
  const SavedSurveysPage({super.key});

  @override
  State<SavedSurveysPage> createState() => _SavedSurveysPageState();
}

class _SavedSurveysPageState extends State<SavedSurveysPage> {
  List<Map<String, dynamic>> _surveys = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSurveys();
  }

  Future<void> _loadSurveys() async {
    final surveys = await SurveyService.getLocalSurveys();
    setState(() {
      _surveys = surveys;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Survey Responses', style: GoogleFonts.poppins()),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSurveys,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _surveys.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No survey responses yet',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete a survey to see responses here',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.green[50],
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Survey Submission Working!',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800],
                                  ),
                                ),
                                Text(
                                  '${_surveys.length} response(s) saved locally',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _surveys.length,
                        itemBuilder: (context, index) {
                          final survey = _surveys[index];
                          final personalInfo = survey['personalInfo'] as Map<String, dynamic>? ?? {};
                          final timestamp = DateTime.parse(survey['timestamp'] ?? DateTime.now().toIso8601String());
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue[100],
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ),
                              title: Text(
                                personalInfo['name']?.isNotEmpty == true 
                                  ? personalInfo['name'] 
                                  : 'Anonymous Response',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Client: ${personalInfo['clientType'] ?? 'Not specified'}',
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                  Text(
                                    'Submitted: ${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                              onTap: () => _showSurveyDetails(survey),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: _surveys.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _clearAllSurveys,
              backgroundColor: Colors.red[600],
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              label: Text(
                'Clear All',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            )
          : null,
    );
  }

  void _showSurveyDetails(Map<String, dynamic> survey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Survey Response Details', style: GoogleFonts.poppins()),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSection('Personal Info', survey['personalInfo']),
              _buildSection('CC Questions', survey['ccQuestions']),
              _buildSection('SQD Questions', survey['sqdQuestions']),
              _buildSection('Feedback', survey['feedback']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...data.entries.map((entry) {
          if (entry.value == null || entry.value.toString().isEmpty) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${entry.key}: ${entry.value}',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          );
        }),
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _clearAllSurveys() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Responses?', style: GoogleFonts.poppins()),
        content: Text(
          'This will permanently delete all ${_surveys.length} saved survey responses.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SurveyService.clearLocalSurveys();
      _loadSurveys();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All survey responses cleared')),
        );
      }
    }
  }
}