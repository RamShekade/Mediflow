import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PatientProfilePage extends StatefulWidget {
  final String patientId;

  const PatientProfilePage({super.key, required this.patientId});

  @override
  _PatientProfilePageState createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  Map<String, dynamic>? patientData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPatientProfile();
  }

  Future<void> fetchPatientProfile() async {
    final response = await http.get(
      Uri.parse(
        'http://192.168.1.5:5000/api/patient/profile/${widget.patientId}',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        patientData = data['patient'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load patient profile')),
      );
    }
  }

  Widget buildInfoTile(String label, String value, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: Colors.blue),
      title: Text(label),
      subtitle: Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Profile'),
        backgroundColor: Colors.teal,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : patientData == null
              ? const Center(child: Text('No data found'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.teal,
                              child: Text(
                                "${patientData!['firstName'][0].toUpperCase()}${patientData!['lastName'][0].toUpperCase()}",
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${patientData!['firstName']} ${patientData!['lastName']}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Age: ${patientData!['age']}, Sex: ${patientData!['sex']}',
                            ),
                            const SizedBox(height: 10),
                            patientData!['gdprConsent'] == true
                                ? Chip(
                                  label: const Text('GDPR Consent Given'),
                                  backgroundColor: Colors.green.shade100,
                                  avatar: const Icon(
                                    Icons.verified_user,
                                    color: Colors.green,
                                  ),
                                )
                                : Chip(
                                  label: const Text('No GDPR Consent'),
                                  backgroundColor: Colors.red.shade100,
                                  avatar: const Icon(
                                    Icons.warning,
                                    color: Colors.red,
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Medical Information
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Medical Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            buildInfoTile(
                              'Conditions',
                              patientData!['conditions'].join(', '),
                              Icons.healing,
                            ),
                            buildInfoTile(
                              'Medications',
                              patientData!['medications'].join(', '),
                              Icons.medication,
                            ),
                            buildInfoTile(
                              'Allergies',
                              patientData!['allergies'].join(', '),
                              Icons.warning_amber,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Pre-visit Reports
                    if (patientData!['preVisitReports'] != null &&
                        patientData!['preVisitReports'].isNotEmpty)
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pre-Visit Reports',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    patientData!['preVisitReports'].length,
                                itemBuilder: (context, index) {
                                  final report =
                                      patientData!['preVisitReports'][index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        'Reason: ${report['reasonForVisit']}',
                                      ),
                                      subtitle: Text(
                                        'Symptom: ${report['mainSymptom']}',
                                      ),
                                      trailing: Icon(
                                        report['sendReportToDoctor']
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color:
                                            report['sendReportToDoctor']
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
    );
  }
}
