import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppointmentSchedulingPage extends StatefulWidget {
  final String userId;

  const AppointmentSchedulingPage({super.key, required this.userId});

  @override
  State<AppointmentSchedulingPage> createState() =>
      _AppointmentSchedulingPageState();
}

class _AppointmentSchedulingPageState extends State<AppointmentSchedulingPage> {
  final TextEditingController reasonController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final String baseUrl = 'http://192.168.1.5:5000/api';
  bool isLoading = false;

  void showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> scheduleAppointment() async {
    if (selectedDate == null ||
        selectedTime == null ||
        reasonController.text.isEmpty) {
      showSnackBar("Please fill all fields.");
      return;
    }

    final DateTime appointmentDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('$baseUrl/patient/appointment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': widget.userId,
        'datetime': appointmentDateTime.toIso8601String(),
        'reason': reasonController.text.trim(),
      }),
    );

    setState(() => isLoading = false);

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      showSnackBar("Appointment Scheduled!");
      Navigator.pop(context);
    } else {
      showSnackBar("Failed: ${data['error'] ?? 'Something went wrong'}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schedule Appointment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Reason for Appointment",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter symptoms or reason",
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Date",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                selectedDate != null
                    ? "${selectedDate!.toLocal()}".split(' ')[0]
                    : "Choose date",
              ),
              onTap: _selectDate,
            ),
            const SizedBox(height: 10),
            const Text(
              "Select Time",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(
                selectedTime != null
                    ? selectedTime!.format(context)
                    : "Choose time",
              ),
              onTap: _selectTime,
            ),
            const SizedBox(height: 30),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                  onPressed: scheduleAppointment,
                  icon: const Icon(Icons.calendar_month),
                  label: const Text("Confirm Appointment"),
                ),
          ],
        ),
      ),
    );
  }
}
