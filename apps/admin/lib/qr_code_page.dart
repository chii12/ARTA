import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'admin_scaffold.dart';

class QRCodePage extends StatefulWidget {
  const QRCodePage({super.key});

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  List<Map<String, dynamic>> _surveys = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSurveys();
  }

  Future<void> _loadSurveys() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() => _loading = false);
        return;
      }
      
      // Get the actual logged-in user's data
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
      
      print('QR Page - User department: ${userResponse['department_id']}');
      
      // Load surveys from the same department
      final response = await Supabase.instance.client
          .from('surveys')
          .select('survey_id, title, qr_code_url, survey_date, department_id')
          .eq('department_id', userResponse['department_id'])
          .order('survey_date', ascending: false);
      
      print('QR Page - Found ${response.length} surveys');
      for (var s in response) {
        print('Survey: ${s['title']}, dept: ${s['department_id']}');
      }
      
      setState(() {
        _surveys = List<Map<String, dynamic>>.from(response);
        _loading = false;
      });
    } catch (e) {
      print('QR Page error: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      selectedRoute: '/admin/qr',
      onNavigate: (route) => Navigator.of(context).pushReplacementNamed(route),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Generate QR Code', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Select a survey to generate QR code', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
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
                                  trailing: ElevatedButton.icon(
                                    onPressed: () => _generateQR(survey),
                                    icon: const Icon(Icons.qr_code, size: 18),
                                    label: const Text('Generate QR'),
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

  void _generateQR(Map<String, dynamic> survey) {
    final surveyId = survey['survey_id'].toString();
    final surveyLink = survey['qr_code_url'] ?? 'https://yourapp.com/survey/$surveyId';
    final qrKey = GlobalKey();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code & Link Generated'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RepaintBoundary(
                key: qrKey,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: QrImageView(
                    data: surveyLink,
                    version: QrVersions.auto,
                    size: 200,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Survey: ${survey['title']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Survey Link:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(
                  surveyLink,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Scan QR code or share this link to access the survey', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: surveyLink));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link copied to clipboard!')),
              );
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy Link'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                final boundary = qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                final image = await boundary.toImage(pixelRatio: 3.0);
                final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                final pngBytes = byteData!.buffer.asUint8List();
                
                await Clipboard.setData(ClipboardData(text: 'QR Code saved'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('QR Code ready! (Save functionality requires platform-specific code)')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Download QR'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/survey/$surveyId');
            },
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Open Survey'),
          ),
        ],
      ),
    );
  }
}
