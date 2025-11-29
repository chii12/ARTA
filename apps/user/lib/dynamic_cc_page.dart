import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cc_pages.dart';
import 'services/survey_service.dart';
import 'feedback_page.dart';

class DynamicCC1Page extends StatefulWidget {
  final Map<String, dynamic> formData;
  final List<Map<String, dynamic>> questions;
  final Map<String, dynamic>? surveyData;
  
  const DynamicCC1Page({
    super.key, 
    required this.formData, 
    required this.questions,
    this.surveyData,
  });

  @override
  State<DynamicCC1Page> createState() => _DynamicCC1PageState();
}

class _DynamicCC1PageState extends State<DynamicCC1Page> {
  int _currentQuestionIndex = 0;
  final Map<String, dynamic> _answers = {};

  Map<String, dynamic> get _currentQuestion => widget.questions[_currentQuestionIndex];
  bool get _isLastQuestion => _currentQuestionIndex >= widget.questions.length - 1;

  void _nextQuestion() {
    if (_isLastQuestion) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FeedbackPage(
            formData: widget.formData,
            answers: _answers,
            surveyData: widget.surveyData,
          ),
        ),
      );
    } else {
      setState(() => _currentQuestionIndex++);
    }
  }



  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    } else {
      Navigator.of(context).pop();
    }
  }



  Widget _buildQuestionWidget() {
    final question = _currentQuestion;
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
          child: Image.asset(
            _getEmojiAsset(_answers[code]),
            height: 180,
            width: 180,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox(height: 180, width: 180),
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
    return _buildSatisfactionRating(code, question); // Same UI for now
  }

  List<String> _getSatisfactionOptions() {
    return [
      'STRONGLY DISAGREE',
      'DISAGREE', 
      'NEITHER AGREE NOR DISAGREE',
      'AGREE',
      'STRONGLY AGREE',
      'NOT APPLICABLE'
    ];
  }

  String _getEmojiAsset(String? selection) {
    if (selection == null) {
      return 'assets/emoticons/NEITHER AGREE NOR DISAGREE-BW.png';
    }
    switch (selection) {
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
            child: Container(color: Colors.black.withValues(alpha: 0.4)),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04,
                        vertical: MediaQuery.of(context).size.height * 0.02,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width < 420
                                ? MediaQuery.of(context).size.width * 0.92
                                : 400,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header
                              Column(
                                children: [
                                  Image.asset(
                                    'assets/logo_headingblk.png',
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.05,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      widget.surveyData != null 
                                        ? 'Custom Survey Questions'
                                        : 'INSTRUCTIONS: Please place a Check mark (✓) in the designated box that corresponds to your answer.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 15,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Progress indicator
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                child: LinearProgressIndicator(
                                  value: (_currentQuestionIndex + 1) / widget.questions.length,
                                  backgroundColor: Colors.white30,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Question ${_currentQuestionIndex + 1} of ${widget.questions.length}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // White content area
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
                                      _buildQuestionWidget(),
                                      const SizedBox(height: 24),
                                      // Navigation buttons
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton(
                                            onPressed: _previousQuestion,
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
                                            onPressed: _answers[_currentQuestion['code']] != null 
                                              ? _nextQuestion 
                                              : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _isLastQuestion 
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
                                              _isLastQuestion ? 'Submit' : 'Next',
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
}