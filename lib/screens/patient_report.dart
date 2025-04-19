import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PatientReportsPage extends StatefulWidget {
  final patientId;

  const PatientReportsPage({required this.patientId, super.key});

  @override
  State<PatientReportsPage> createState() => _PatientReportsPageState();
}

class _PatientReportsPageState extends State<PatientReportsPage> {
  late Future<List<Map<String, dynamic>>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = fetchReports();
  }

  Future<List<Map<String, dynamic>>> fetchReports() async {
    final response = await http.get(
      Uri.parse(
        'http://192.168.1.5:5000/api/doctor/previsit/${widget.patientId}',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);

      // Check if it's a list or a single map
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else if (data is Map<String, dynamic>) {
        return [data]; // Wrap single map into a list
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load reports');
    }
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📝 Main Complaint: ${report['mainComplaint'] ?? 'N/A'}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("📅 Duration: ${report['duration'] ?? 'N/A'}"),
            Text("📊 Severity: ${report['severity'] ?? 'N/A'}"),
            Text("🔁 Frequency: ${report['frequency'] ?? 'N/A'}"),
            const SizedBox(height: 10),

            if (report['medications'] != null &&
                report['medications'].isNotEmpty)
              Text(
                "💊 Medications: ${(report['medications'] as List).join(', ')}",
              ),

            if (report['pastMedicalHistory'] != null &&
                report['pastMedicalHistory'].isNotEmpty)
              Text(
                "📚 Medical History: ${(report['pastMedicalHistory'] as List).join(', ')}",
              ),

            if (report['allergies'] != null && report['allergies'].isNotEmpty)
              Text("⚠️ Allergies: ${(report['allergies'] as List).join(', ')}"),

            Text(
              "🏃 Lifestyle Info: ${report['lifestyleInfo'] ?? 'Not mentioned'}",
            ),
            Text(
              "🗒️ Additional Notes: ${report['additionalNotes'] ?? 'None'}",
            ),

            const SizedBox(height: 10),
            if (report['createdAt'] != null && report['createdAt'] is String)
              Text(
                "🕒 Created At: ${DateTime.tryParse(report['createdAt'])?.toLocal().toString() ?? 'Invalid date'}",
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patient Reports")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("❌ Error: ${snapshot.error}"));
          }
          final reports = snapshot.data!;
          if (reports.isEmpty) {
            return const Center(
              child: Text("No reports found for this patient."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              return _buildReportCard(reports[index]);
            },
          );
        },
      ),
    );
  }
}
