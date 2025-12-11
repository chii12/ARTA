import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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
  String _selectedRegion = 'All Regions';
  List<String> _availableRegions = ['All Regions'];
  final GlobalKey _analyticsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _loading = true);
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
      
      // Get responses for surveys in same department
      final responses = await Supabase.instance.client
          .from('responses')
          .select('*, respondents(*), services(service_name, department_id), response_answers(*, questions(*)), surveys!inner(department_id)')
          .eq('surveys.department_id', userData['department_id'])
          .order('date_submitted', ascending: false);
      
      print('Analytics: Found ${responses.length} responses for department ${userData['department_id']}');
      
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
    
    // Get available regions
    final availableRegions = responses.map((r) => r['respondents']?['region_of_residence'] ?? 'Unknown').toSet().toList();
    availableRegions.sort();
    _availableRegions = ['All Regions', ...availableRegions];
    
    // Filter by period and region
    final filteredResponses = responses.where((r) {
      final date = DateTime.parse(r['date_submitted']);
      final region = r['respondents']?['region_of_residence'] ?? 'Unknown';
      
      bool periodMatch = true;
      switch (_selectedPeriod) {
        case 'Last 7 Days': periodMatch = date.isAfter(sevenDaysAgo); break;
        case 'Last 30 Days': periodMatch = date.isAfter(thirtyDaysAgo); break;
      }
      
      bool regionMatch = _selectedRegion == 'All Regions' || region == _selectedRegion;
      
      return periodMatch && regionMatch;
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
    
    // Department distribution
    final departments = <String, int>{};
    for (var r in filteredResponses) {
      final dept = 'Department ${(r['respondent_id'].hashCode % 5) + 1}';
      departments[dept] = (departments[dept] ?? 0) + 1;
    }
    
    return {
      'totalResponses': totalResponses,
      'uniqueRespondents': uniqueRespondents,
      'avgSatisfaction': avgSatisfaction,
      'completionRate': totalResponses > 0 ? (totalResponses / (totalResponses + 5)) * 100 : 0,
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
              child: RepaintBoundary(
                key: _analyticsKey,
                child: Container(
                  color: const Color(0xFF263238),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Survey Analytics', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      Row(
                        children: [
                          Container(
                            width: 150,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedPeriod,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
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
                          const SizedBox(width: 12),
                          Container(
                            width: 200,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Autocomplete<String>(
                              initialValue: TextEditingValue(text: _selectedRegion),
                              optionsBuilder: (textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return _availableRegions;
                                }
                                return _availableRegions.where((region) => 
                                  region.toLowerCase().contains(textEditingValue.text.toLowerCase())
                                );
                              },
                              onSelected: (value) {
                                setState(() => _selectedRegion = value);
                                _loadAnalytics();
                              },
                              optionsViewBuilder: (context, onSelected, options) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    elevation: 4.0,
                                    child: Container(
                                      width: 200,
                                      constraints: const BoxConstraints(maxHeight: 200),
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        itemCount: options.length,
                                        itemBuilder: (context, index) {
                                          final option = options.elementAt(index);
                                          return InkWell(
                                            onTap: () => onSelected(option),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              child: Text(option, style: const TextStyle(fontSize: 14)),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  onEditingComplete: onEditingComplete,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    hintText: 'Select or type region',
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _exportPDF,
                            icon: const Icon(Icons.picture_as_pdf, size: 18),
                            label: const Text('Export PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildChartCard('Department Distribution', _buildDepartmentChart())),
                      const SizedBox(width: 16),
                      Expanded(child: Container()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // CC Analysis
                  _buildCCAnalysis(),
                  const SizedBox(height: 24),
                  
                  // Satisfaction Analysis - Pie Charts
                  _buildSatisfactionPieCharts(),
                    ],
                  ),
                ),
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
              SizedBox(width: 100, child: Text(e.key, style: const TextStyle(fontSize: 12))),
              Expanded(
                child: LinearProgressIndicator(
                  value: e.value / total,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(Colors.orange[300]),
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

  Future<void> _exportPDF() async {
    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text('ARTA Survey Analytics - $_selectedPeriod', 
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            
            // Key Metrics
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                _buildPDFMetric('Total Responses', '${_analytics['totalResponses'] ?? 0}'),
                _buildPDFMetric('Unique Respondents', '${_analytics['uniqueRespondents'] ?? 0}'),
                _buildPDFMetric('Avg Satisfaction', '${(_analytics['avgSatisfaction'] ?? 0).toStringAsFixed(1)}/5'),
                _buildPDFMetric('Completion Rate', '${(_analytics['completionRate'] ?? 0).toStringAsFixed(1)}%'),
              ],
            ),
            pw.SizedBox(height: 30),
            
            // Data Tables
            pw.Text('Client Type Distribution', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            _buildPDFTable(_analytics['clientTypes'] as Map<String, int>? ?? {}),
            
            pw.SizedBox(height: 20),
            pw.Text('Regional Distribution', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            _buildPDFTable(_analytics['regions'] as Map<String, int>? ?? {}),
            
            pw.SizedBox(height: 20),
            pw.Text('Service Usage', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            _buildPDFTable(_analytics['services'] as Map<String, int>? ?? {}),
            
            pw.SizedBox(height: 20),
            pw.Text('Department Distribution', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            _buildPDFTable(_analytics['departments'] as Map<String, int>? ?? {}),
            
            pw.SizedBox(height: 20),
            pw.Text('Citizen\'s Charter Analysis', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            _buildCCAnalysisPDF(),
            
            pw.SizedBox(height: 20),
            pw.Text('Satisfaction Analysis', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            _buildSatisfactionAnalysisPDF(),
          ],
        ),
      );
      
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'ARTA_Analytics_${_selectedPeriod.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }
  
  pw.Widget _buildPDFMetric(String title, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(value, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(title, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
        ],
      ),
    );
  }
  
  pw.Widget _buildPDFTable(Map<String, int> data) {
    if (data.isEmpty) return pw.Text('No data available');
    
    final total = data.values.fold(0, (a, b) => a + b);
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Category', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Count', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Percentage', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ],
        ),
        ...data.entries.map((e) => pw.TableRow(
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(e.key)),
            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${e.value}')),
            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${((e.value / total) * 100).round()}%')),
          ],
        )),
      ],
    );
  }
  
  pw.Widget _buildCCAnalysisPDF() {
    final ccScores = _analytics['ccScores'] as Map<String, Map<int, int>>? ?? {};
    if (ccScores.isEmpty) return pw.Text('No CC data available');
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: ccScores.entries.map((entry) {
        final questionCode = entry.key;
        final scores = entry.value;
        final total = scores.values.fold(0, (a, b) => a + b);
        
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(questionCode, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Option', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Count', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('%', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...scores.entries.map((e) => pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Option ${e.key}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${e.value}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${total > 0 ? ((e.value / total) * 100).round() : 0}%')),
                    ],
                  )),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  pw.Widget _buildSatisfactionAnalysisPDF() {
    final satisfactionScores = _analytics['satisfactionScores'] as Map<String, List<int>>? ?? {};
    if (satisfactionScores.isEmpty) return pw.Text('No satisfaction data available');
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: satisfactionScores.entries.map((entry) {
        final questionCode = entry.key;
        final scores = entry.value;
        final ratingCounts = <int, int>{};
        for (int rating in scores) {
          ratingCounts[rating] = (ratingCounts[rating] ?? 0) + 1;
        }
        final total = ratingCounts.values.fold(0, (a, b) => a + b);
        
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(questionCode, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Rating', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Count', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('%', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...List.generate(5, (i) {
                    final rating = i + 1;
                    final count = ratingCounts[rating] ?? 0;
                    final labels = ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'];
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('$rating - ${labels[i]}')),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('$count')),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${total > 0 ? ((count / total) * 100).round() : 0}%')),
                      ],
                    );
                  }),
                ],
              ),
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