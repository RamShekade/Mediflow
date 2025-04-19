import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DoctorProfileOnboarding extends StatefulWidget {
  final String userId;
  const DoctorProfileOnboarding({super.key, required this.userId});

  @override
  State<DoctorProfileOnboarding> createState() =>
      _DoctorProfileOnboardingState();
}

class _DoctorProfileOnboardingState extends State<DoctorProfileOnboarding> {
  final TextEditingController specializationController =
      TextEditingController();
  final TextEditingController clinicNameController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  bool isLoading = false;

  final String baseUrl = 'http://192.168.1.5:5000/api'; // Your backend URL

  Future<void> submitDoctorProfile() async {
    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('$baseUrl/doctor/onboarding'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': widget.userId,
        'specialization': specializationController.text.trim(),
        'clinicName': clinicNameController.text.trim(),
        'licenseNumber': licenseNumberController.text.trim(),
      }),
    );

    setState(() => isLoading = false);

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      showSnackBar("Doctor profile submitted successfully");
      // Navigate to doctor dashboard or home
    } else {
      showSnackBar("Failed: ${data['error'] ?? 'Unknown error'}");
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Doctor Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text(
              "Please fill out the following:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: specializationController,
              decoration: const InputDecoration(labelText: "Specialization"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: clinicNameController,
              decoration: const InputDecoration(labelText: "Clinic Name"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: licenseNumberController,
              decoration: const InputDecoration(labelText: "License Number"),
            ),
            const SizedBox(height: 30),

            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: submitDoctorProfile,
                  child: const Text("Submit"),
                ),
          ],
        ),
      ),
    );
  }
}
