import 'package:flutter/material.dart';
import 'analytics_service.dart';

class AdminAnalytics extends StatefulWidget {
  final String userDepartmentId;
  
  const AdminAnalytics({super.key, required this.userDepartmentId});

  @override
  State<AdminAnalytics> createState() => _AdminAnalyticsState();
}

class _AdminAnalyticsState extends State<AdminAnalytics> {
  Map<String, dynamic> analytics = {};
  List<Map<String, dynamic>> recentResponses = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final analyticsData = await AnalyticsService.getDepartmentAnalytics(widget.userDepartmentId);
    final responsesData = await AnalyticsService.getRecentResponses(widget.userDepartmentId);
    
    if (mounted) {
      setState(() {
        analytics = analyticsData;
        recentResponses = responsesData;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Analytics Cards
        Row(
          children: [
            Expanded(child: _buildAnalyticsCard('Total Surveys', '${analytics['totalSurveys']}', Icons.poll)),
            const SizedBox(width: 16),
            Expanded(child: _buildAnalyticsCard('Total Responses', '${analytics['totalResponses']}', Icons.people)),
            const SizedBox(width: 16),
            Expanded(child: _buildAnalyticsCard('Avg Rating', '${analytics['averageRating'].toStringAsFixed(1)}', Icons.star)),
            const SizedBox(width: 16),
            Expanded(child: _buildAnalyticsCard('Satisfaction', '${analytics['satisfactionRate'].toStringAsFixed(1)}%', Icons.thumb_up)),
          ],
        ),
        const SizedBox(height: 24),
        
        // Recent Responses
        const Text('Recent Responses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: recentResponses.isEmpty
                ? [const Padding(padding: EdgeInsets.all(16), child: Text('No responses yet'))]
                : recentResponses.map((response) => _buildResponseTile(response)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseTile(Map<String, dynamic> response) {
    final respondent = response['respondents'];
    final service = response['services'];
    
    return ListTile(
      title: Text(response['survey_title'] ?? 'Unknown Survey'),
      subtitle: Text('${respondent?['name'] ?? 'Anonymous'} - ${service?['service_name'] ?? 'No Service'}'),
      trailing: Text(
        DateTime.parse(response['date_submitted']).toString().split(' ')[0],
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}