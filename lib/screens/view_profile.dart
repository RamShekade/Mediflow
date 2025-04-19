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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Profile')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : patientData == null
              ? const Center(child: Text('No data found'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    // Patient's Name
                    Text(
                      '${patientData!['firstName']} ${patientData!['lastName']}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Patient's Personal Details
                    Text('Age: ${patientData!['age']}'),
                    Text('Sex: ${patientData!['sex']}'),
                    const SizedBox(height: 20),
                    // Patient's Contact Details
                    Text('Contact Info:'),
                    Text('Phone: ${patientData!['contact']['phone']}'),
                    Text('Email: ${patientData!['contact']['email']}'),
                    const SizedBox(height: 20),
                    // Patient's Address
                    Text('Address:'),
                    Text(
                      '${patientData!['address']['street']}, ${patientData!['address']['city']}, ${patientData!['address']['state']}, ${patientData!['address']['zip']}, ${patientData!['address']['country']}',
                    ),
                    const SizedBox(height: 20),
                    // Emergency Contact
                    Text('Emergency Contact:'),
                    Text('Name: ${patientData!['emergencyContact']['name']}'),
                    Text('Phone: ${patientData!['emergencyContact']['phone']}'),
                    Text(
                      'Relationship: ${patientData!['emergencyContact']['relationship']}',
                    ),
                    const SizedBox(height: 20),
                    // Patient's Medical History
                    Text('Medical History:', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    if (patientData!['conditions'].isNotEmpty)
                      Text(
                        'Conditions: ${patientData!['conditions'].join(', ')}',
                      ),
                    if (patientData!['medications'].isNotEmpty)
                      Text(
                        'Medications: ${patientData!['medications'].join(', ')}',
                      ),
                    if (patientData!['allergies'].isNotEmpty)
                      Text(
                        'Allergies: ${patientData!['allergies'].join(', ')}',
                      ),
                    const SizedBox(height: 20),
                    // Pre-visit Reports
                    Text('Pre-Visit Reports:', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    if (patientData!['preVisitReports'].isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: patientData!['preVisitReports'].length,
                        itemBuilder: (context, index) {
                          final report = patientData!['preVisitReports'][index];
                          return Card(
                            child: ListTile(
                              title: Text(
                                'Reason for Visit: ${report['reasonForVisit']}',
                              ),
                              subtitle: Text(
                                'Main Symptom: ${report['mainSymptom']}',
                              ),
                              trailing:
                                  report['sendReportToDoctor']
                                      ? Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                      : Icon(Icons.cancel, color: Colors.red),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
    );
  }
}
