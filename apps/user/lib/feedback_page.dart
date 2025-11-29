import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cc_pages.dart';
import 'services/survey_service.dart';

class FeedbackPage extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Map<String, dynamic> answers;
  final Map<String, dynamic>? surveyData;
  
  const FeedbackPage({
    super.key,
    required this.formData,
    required this.answers,
    this.surveyData,
  });

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _suggestionsController = TextEditingController();
  final _emailController = TextEditingController();

  void _submitSurvey() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
    
    try {
      final allData = Map<String, dynamic>.from(widget.formData);
      allData.addAll(widget.answers);
      allData['suggestions'] = _suggestionsController.text;
      allData['email'] = _emailController.text;
      
      final surveyResponse = SurveyService.createSurveyResponse(
        name: allData['name'] ?? '',
        clientType: allData['clientType'] ?? '',
        sex: allData['sex'] ?? '',
        date: allData['date'] ?? '',
        age: allData['age'] ?? '',
        region: allData['region'] ?? '',
        service: allData['service'] ?? '',
        cc1: allData['CC1'],
        cc2: allData['CC2'],
        cc3: allData['CC3'],
        sqd0: allData['SQD0'],
        sqd1: allData['SQD1'],
        sqd2: allData['SQD2'],
        sqd3: allData['SQD3'],
        sqd4: allData['SQD4'],
        sqd5: allData['SQD5'],
        sqd6: allData['SQD6'],
        sqd7: allData['SQD7'],
        sqd8: allData['SQD8'],
        suggestions: allData['suggestions'] ?? '',
        email: allData['email'] ?? '',
        departmentId: widget.surveyData?['department_id'],
      );
      
      final success = await SurveyService.submitSurveyToAPI(surveyResponse);
      
      if (mounted) {
        Navigator.of(context).pop();
        
        if (success) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ResponseRecordedPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit survey. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Feedback',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Content Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Help us improve our services',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Suggestions Field
                      Text(
                        'Suggestions on how we can further improve our services (optional):',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _suggestionsController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Share your suggestions...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Email Field
                      Text(
                        'Email address (optional):',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'your.email@example.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      
                      const Spacer(),
                      
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _submitSurvey,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: Color(0xFF6366F1)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Skip',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6366F1),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _submitSurvey,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Submit Survey',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
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
    );
  }
}