import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_scaffold.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  Map<String, dynamic> _analytics = {};
  bool _loading = true;
  String _selectedPeriod = 'Last 30 Days';

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _loading = true);
    try {
      // Get all responses from all departments (super admin view)
      final responses = await Supabase.instance.client
          .from('responses')
          .select('*, respondents(*), services(service_name, department_id, departments(department_name)), response_answers(*, questions(*))')
          .order('date_submitted', ascending: false);
      
      print('Analytics: Found ${responses.length} responses across all departments');
      
      // Calculate analytics
      final analytics = _calculateAnalytics(responses);
      
      setState(() {
        _analytics = analytics;
        _loading = false;
      });
    } catch (e) {
      print('Analytics error: $e');
      setState(() => _loading = false);
    }
  }

  Map<String, dynamic> _calculateAnalytics(List<dynamic> responses) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    
    // Filter by period
    final filteredResponses = responses.where((r) {
      final date = DateTime.parse(r['date_submitted']);
      switch (_selectedPeriod) {
        case 'Last 7 Days': return date.isAfter(sevenDaysAgo);
        case 'Last 30 Days': return date.isAfter(thirtyDaysAgo);
        default: return true;
      }
    }).toList();
    
    // Basic metrics
    final totalResponses = filteredResponses.length;
    final uniqueRespondents = filteredResponses.map((r) => r['respondent_id']).toSet().length;
    
    // Client type distribution
    final clientTypes = <String, int>{};
    for (var r in filteredResponses) {
      final type = r['respondents']?['client_type'] ?? 'Unknown';
      clientTypes[type] = (clientTypes[type] ?? 0) + 1;
    }
    
    // Region distribution
    final regions = <String, int>{};
    for (var r in filteredResponses) {
      final region = r['respondents']?['region_of_residence'] ?? 'Unknown';
      regions[region] = (regions[region] ?? 0) + 1;
    }
    
    // Service distribution (case-insensitive grouping)
    final services = <String, int>{};
    final serviceDisplayNames = <String, String>{}; // lowercase -> display name
    for (var r in filteredResponses) {
      final service = r['services']?['service_name'] ?? 'Unknown';
      final serviceLower = service.toLowerCase();
      final displayName = service.split(' ').map((word) => 
        word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase()
      ).join(' ');
      
      services[serviceLower] = (services[serviceLower] ?? 0) + 1;
      serviceDisplayNames[serviceLower] = displayName;
    }
    
    // Convert to display format
    final servicesDisplay = <String, int>{};
    services.forEach((key, value) {
      servicesDisplay[serviceDisplayNames[key]!] = value;
    });
    
    // Department distribution
    final departments = <String, int>{};
    for (var r in filteredResponses) {
      final deptName = r['services']?['departments']?['department_name'] ?? 'Unknown Department';
      departments[deptName] = (departments[deptName] ?? 0) + 1;
    }
    
    // CC and Satisfaction scores
    final ccScores = <String, Map<int, int>>{};
    final satisfactionScores = <String, List<int>>{};
    double avgSatisfaction = 0;
    int satisfactionCount = 0;
    
    for (var r in filteredResponses) {
      final answers = r['response_answers'] as List? ?? [];
      for (var answer in answers) {
        final questionCode = answer['questions']?['question_code'];
        final ratingValue = answer['rating_value'];
        final textAnswer = answer['text_answer'];
        
        if (questionCode != null) {
          if (questionCode.startsWith('CC')) {
            // CC questions use text answers, convert to option numbers
            if (textAnswer != null && textAnswer.isNotEmpty) {
              int optionNumber = 1; // Default to option 1
              
              // Map text answers to option numbers based on common CC responses
              if (textAnswer.contains('know') && textAnswer.contains('saw')) {
                optionNumber = 1;
              } else if (textAnswer.contains('know') && textAnswer.contains('not')) {
                optionNumber = 2;
              } else if (textAnswer.contains('learned')) {
                optionNumber = 3;
              } else if (textAnswer.contains('not know') || textAnswer.contains('do not')) {
                optionNumber = 4;
              } else if (textAnswer.contains('Easy')) {
                optionNumber = 1;
              } else if (textAnswer.contains('Somewhat')) {
                optionNumber = 2;
              } else if (textAnswer.contains('Difficult')) {
                optionNumber = 3;
              } else if (textAnswer.contains('Not visible')) {
                optionNumber = 4;
              } else if (textAnswer.contains('very much')) {
                optionNumber = 1;
              } else if (textAnswer.contains('helped')) {
                optionNumber = 2;
              } else if (textAnswer.contains('not help')) {
                optionNumber = 3;
              }
              
              ccScores[questionCode] = ccScores[questionCode] ?? {};
              ccScores[questionCode]![optionNumber] = (ccScores[questionCode]![optionNumber] ?? 0) + 1;
            }
          } else if (questionCode.startsWith('SQD')) {
            if (ratingValue != null && ratingValue > 0) {
              satisfactionScores[questionCode] = (satisfactionScores[questionCode] ?? [])..add(ratingValue);
              avgSatisfaction += ratingValue;
              satisfactionCount++;
            }
          }
        }
      }
    }
    
    print('Total satisfaction scores: ${satisfactionScores.length}');
    print('Satisfaction scores: $satisfactionScores');
    print('CC scores found: ${ccScores.length}');
    print('CC scores: $ccScores');
    
    if (satisfactionCount > 0) {
      avgSatisfaction = avgSatisfaction / satisfactionCount;
    }
    
    // Daily response trend
    final dailyTrend = <String, int>{};
    for (var r in filteredResponses) {
      final date = DateTime.parse(r['date_submitted']);
      final dateKey = '${date.month}/${date.day}';
      dailyTrend[dateKey] = (dailyTrend[dateKey] ?? 0) + 1;
    }
    
    return {
      'totalResponses': totalResponses,
      'uniqueRespondents': uniqueRespondents,
      'avgSatisfaction': avgSatisfaction,
      'completionRate': totalResponses > 0 ? (totalResponses / (totalResponses + 5)) * 100 : 0, // Mock incomplete responses
      'clientTypes': clientTypes,
      'regions': regions,
      'services': servicesDisplay,
      'departments': departments,
      'ccScores': ccScores,
      'satisfactionScores': satisfactionScores,
      'dailyTrend': dailyTrend,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      selectedRoute: '/admin/analytics',
      onNavigate: (route) => Navigator.of(context).pushReplacementNamed(route),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Survey Analytics', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedPeriod,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'Last 7 Days', child: Text('Last 7 Days')),
                            DropdownMenuItem(value: 'Last 30 Days', child: Text('Last 30 Days')),
                            DropdownMenuItem(value: 'All Time', child: Text('All Time')),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedPeriod = value!);
                            _loadAnalytics();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Key Metrics Cards
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard('Total Responses', '${_analytics['totalResponses'] ?? 0}', Icons.poll, Colors.blue)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildMetricCard('Unique Respondents', '${_analytics['uniqueRespondents'] ?? 0}', Icons.people, Colors.green)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildMetricCard('Avg Satisfaction', '${(_analytics['avgSatisfaction'] ?? 0).toStringAsFixed(1)}/5', Icons.sentiment_satisfied, Colors.orange)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildMetricCard('Completion Rate', '${(_analytics['completionRate'] ?? 0).toStringAsFixed(1)}%', Icons.check_circle, Colors.purple)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Charts Row 1
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildChartCard('Client Type Distribution', _buildClientTypeChart())),
                      const SizedBox(width: 16),
                      Expanded(child: _buildChartCard('Response Trend', _buildTrendChart())),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Charts Row 2
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildChartCard('Regional Distribution', _buildRegionChart())),
                      const SizedBox(width: 16),
                      Expanded(child: _buildChartCard('Service Usage', _buildServiceChart())),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Department Distribution
                  _buildChartCard('Department Distribution', _buildDepartmentChart()),
                  const SizedBox(height: 24),
                  
                  // CC Analysis
                  _buildCCAnalysis(),
                  const SizedBox(height: 24),
                  
                  // Satisfaction Analysis - Pie Charts
                  _buildSatisfactionPieCharts(),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Icon(Icons.trending_up, color: Colors.green, size: 16),
              ],
            ),
            const SizedBox(height: 16),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildClientTypeChart() {
    final clientTypes = _analytics['clientTypes'] as Map<String, int>? ?? {};
    if (clientTypes.isEmpty) return const Center(child: Text('No data available'));
    
    final total = clientTypes.values.fold(0, (a, b) => a + b);
    return Column(
      children: clientTypes.entries.map((e) {
        final percentage = (e.value / total * 100).round();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(width: 80, child: Text(e.key, style: const TextStyle(fontSize: 12))),
              Expanded(
                child: LinearProgressIndicator(
                  value: e.value / total,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(Colors.blue[300]),
                ),
              ),
              const SizedBox(width: 8),
              Text('$percentage%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrendChart() {
    final dailyTrend = _analytics['dailyTrend'] as Map<String, int>? ?? {};
    if (dailyTrend.isEmpty) return const Center(child: Text('No data available'));
    
    final maxValue = dailyTrend.values.fold(0, (a, b) => a > b ? a : b).toDouble();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: dailyTrend.entries.take(7).map((e) {
        final height = maxValue > 0 ? (e.value / maxValue * 150) : 0;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: height.toDouble(),
                  decoration: BoxDecoration(
                    color: Colors.blue[400],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(e.key, style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRegionChart() {
    final regions = _analytics['regions'] as Map<String, int>? ?? {};
    if (regions.isEmpty) return const Center(child: Text('No data available'));
    
    return ListView(
      children: regions.entries.take(5).map((e) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green[100],
            child: Text('${e.value}', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
          ),
          title: Text(e.key, style: const TextStyle(fontSize: 14)),
          trailing: Text('${e.value} responses', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        );
      }).toList(),
    );
  }

  Widget _buildServiceChart() {
    final services = _analytics['services'] as Map<String, int>? ?? {};
    if (services.isEmpty) return const Center(child: Text('No data available'));
    
    return ListView(
      children: services.entries.take(5).map((e) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.purple[100],
            child: Text('${e.value}', style: TextStyle(color: Colors.purple[700], fontWeight: FontWeight.bold)),
          ),
          title: Text(e.key, style: const TextStyle(fontSize: 14)),
          trailing: Text('${e.value} uses', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        );
      }).toList(),
    );
  }

  Widget _buildDepartmentChart() {
    final departments = _analytics['departments'] as Map<String, int>? ?? {};
    if (departments.isEmpty) return const Center(child: Text('No data available'));
    
    final total = departments.values.fold(0, (a, b) => a + b);
    return Column(
      children: departments.entries.map((e) {
        final percentage = (e.value / total * 100).round();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(width: 120, child: Text(e.key, style: const TextStyle(fontSize: 12))),
              Expanded(
                child: LinearProgressIndicator(
                  value: e.value / total,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(Colors.indigo[400]),
                ),
              ),
              const SizedBox(width: 8),
              Text('$percentage% (${e.value})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSatisfactionPieCharts() {
    final satisfactionScores = _analytics['satisfactionScores'] as Map<String, List<int>>? ?? {};
    if (satisfactionScores.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('Satisfaction Analysis', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              const Center(child: Text('No satisfaction data available')),
            ],
          ),
        ),
      );
    }
    
    // Calculate overall SQD scores
    final overallScores = <int>[];
    satisfactionScores.values.forEach((scores) => overallScores.addAll(scores));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Satisfaction Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        // Overall SQD Chart
        _buildSQDPieChart('Overall SQD', overallScores),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
          ),
          itemCount: satisfactionScores.length,
          itemBuilder: (context, index) {
            final entry = satisfactionScores.entries.elementAt(index);
            return _buildSQDPieChart(entry.key, entry.value);
          },
        ),
      ],
    );
  }
  
  Widget _buildSQDPieChart(String questionCode, List<int> scores) {
    final ratingCounts = <int, int>{};
    for (int rating in scores) {
      ratingCounts[rating] = (ratingCounts[rating] ?? 0) + 1;
    }
    
    final colors = [Colors.red, Colors.orange, Colors.yellow, Colors.lightGreen, Colors.green];
    final labels = ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'];
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: Column(
            children: [
              Text(questionCode, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    // Legend on left
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) {
                          final rating = i + 1;
                          final count = ratingCounts[rating] ?? 0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Container(width: 12, height: 12, color: colors[i]),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '($rating): ${labels[i]}',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    // Pie chart on right
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: CustomPaint(
                            size: const Size(150, 150),
                            painter: PieChartPainter(ratingCounts, colors),
                          ),
                        ),
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
  
  Widget _buildCCAnalysis() {
    final ccScores = _analytics['ccScores'] as Map<String, Map<int, int>>? ?? {};
    if (ccScores.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('Citizen\'s Charter Analysis', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              const Center(child: Text('No CC data available')),
            ],
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Citizen\'s Charter Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
          ),
          itemCount: ccScores.length,
          itemBuilder: (context, index) {
            final entry = ccScores.entries.elementAt(index);
            return _buildCCPieChart(entry.key, entry.value);
          },
        ),
      ],
    );
  }
  
  Widget _buildCCPieChart(String questionCode, Map<int, int> ratingCounts) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.purple];
    
    // Get labels based on question code
    List<String> labels;
    switch (questionCode) {
      case 'CC1':
        labels = [
          'Know and saw CC',
          'Know but did not see',
          'Learned when saw',
          'Do not know',
          'N/A'
        ];
        break;
      case 'CC2':
        labels = [
          'Easy to see',
          'Somewhat easy',
          'Difficult to see',
          'Not visible',
          'N/A'
        ];
        break;
      case 'CC3':
        labels = [
          'Helped very much',
          'Somewhat helped',
          'Did not help',
          'N/A',
          'N/A'
        ];
        break;
      default:
        labels = ['Option 1', 'Option 2', 'Option 3', 'Option 4', 'Option 5'];
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: Column(
            children: [
              Text(questionCode, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    // Legend on left
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) {
                          final option = i + 1;
                          final count = ratingCounts[option] ?? 0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Container(width: 12, height: 12, color: colors[i]),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '($option): ${labels[i]}',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    // Pie chart on right
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: CustomPaint(
                            size: const Size(150, 150),
                            painter: PieChartPainter(ratingCounts, colors),
                          ),
                        ),
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
}

class PieChartPainter extends CustomPainter {
  final Map<int, int> data;
  final List<Color> colors;
  
  PieChartPainter(this.data, this.colors);
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    final total = data.values.fold(0, (a, b) => a + b);
    
    if (total == 0) return;
    
    double startAngle = -90 * 3.14159 / 180;
    
    for (int rating = 1; rating <= 5; rating++) {
      final count = data[rating] ?? 0;
      if (count > 0) {
        final sweepAngle = (count / total) * 2 * 3.14159;
        final paint = Paint()
          ..color = colors[rating - 1]
          ..style = PaintingStyle.fill;
        
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          true,
          paint,
        );
        
        // Draw percentage text
        final percentage = ((count / total) * 100).round();
        if (percentage >= 5) { // Only show percentage if slice is big enough
          final textAngle = startAngle + sweepAngle / 2;
          final textRadius = radius * 0.7;
          final textX = center.dx + textRadius * cos(textAngle);
          final textY = center.dy + textRadius * sin(textAngle);
          
          final textPainter = TextPainter(
            text: TextSpan(
              text: '$percentage%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
          );
        }
        
        startAngle += sweepAngle;
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}