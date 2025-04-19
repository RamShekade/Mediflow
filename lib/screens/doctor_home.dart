import 'dart:async';
import 'dart:convert';
import 'package:MediFlow/screens/patient_report.dart';
import 'package:MediFlow/screens/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DoctorHomePage extends StatefulWidget {
  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  Map<String, dynamic>? doctorData;
  List<dynamic> filteredPatients = [];
  List<dynamic> upcomingAppointments = [];
  bool isLoading = true;
  String userName = '';
  String email = '';
  String userId = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserData();
    await fetchDoctorProfile();
    await fetchUpcomingAppointments();
    await fetchAllAppointments();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
      userName = prefs.getString('username') ?? 'User';
      email = prefs.getString('email') ?? 'No Email';
    });
  }

  List<dynamic> allAppointments = [];

  Future<void> fetchAllAppointments() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.5:5000/api/doctor/appointments'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['appointments'] is List) {
          setState(() {
            allAppointments = data['appointments'];
          });
        }
      }
    } catch (e) {
      print("Error fetching all appointments: $e");
    }
  }

  Future<void> fetchDoctorProfile() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.5:5000/api/doctor/profile/$userId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          doctorData = data["doctor"];
          filteredPatients = (doctorData?['patients'] as List<dynamic>?) ?? [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching doctor profile')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchUpcomingAppointments() async {
    final response = await http.get(
      Uri.parse(
        'http://192.168.1.5:5000/api/doctor/appointments/upcoming/$userId',
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['appointments'] is List) {
        setState(() {
          upcomingAppointments = data['appointments'];
        });
      }
    }
  }

  Widget buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : doctorData == null
              ? const Center(child: Text('No data found'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, Dr. $userName',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// Doctor Profile Card
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildSectionHeader("Doctor Profile", Icons.person),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  color: Colors.blueAccent,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Name: ",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "Dr. $userName",
                                    style: GoogleFonts.poppins(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.email_outlined,
                                  color: Colors.blueAccent,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Email: ",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "$email",
                                    style: GoogleFonts.poppins(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.local_hospital_outlined,
                                  color: Colors.blueAccent,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Clinic: ",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "${doctorData!['clinicName']}",
                                    style: GoogleFonts.poppins(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.category_outlined,
                                  color: Colors.blueAccent,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Specialization: ",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "${doctorData!['specialization']}",
                                    style: GoogleFonts.poppins(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.confirmation_num_outlined,
                                  color: Colors.blueAccent,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "License #: ",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "${doctorData!['licenseNumber']}",
                                    style: GoogleFonts.poppins(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.code_outlined,
                                  color: Colors.blueAccent,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Invite Code: ",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "${doctorData!['inviteCode']}",
                                    style: GoogleFonts.poppins(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Appointment Schedule Section
                    buildSectionHeader("All Appointments", Icons.schedule),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = allAppointments[index];
                        final patient = appointment['patientId'];
                        final name =
                            patient != null
                                ? "${patient['firstName']} ${patient['lastName']}"
                                : 'N/A';
                        final datetime = DateTime.parse(
                          appointment['datetime'],
                        );
                        final formattedDate =
                            "${datetime.day}/${datetime.month}/${datetime.year} ${datetime.hour}:${datetime.minute.toString().padLeft(2, '0')}";

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            title: Text(
                              "Patient: $name",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              "Date: $formattedDate\nReason: ${appointment['reason']}",
                              style: GoogleFonts.poppins(),
                            ),
                            trailing: Text(
                              appointment['status'],
                              style: GoogleFonts.poppins(
                                color:
                                    appointment['status'] == 'Completed'
                                        ? Colors.green
                                        : appointment['status'] == 'Cancelled'
                                        ? Colors.red
                                        : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    /// Connected Patients
                    buildSectionHeader("Connected Patients", Icons.group),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredPatients.length,
                      itemBuilder: (context, index) {
                        final patient = filteredPatients[index];
                        final user = patient['userId'];
                        final name =
                            user != null
                                ? user['name'] ?? 'N/A'
                                : '${patient['firstName']} ${patient['lastName']}';
                        final gender =
                            user != null
                                ? user['gender'] ?? 'N/A'
                                : patient['sex'] ?? 'N/A';
                        final age =
                            user != null
                                ? user['age']?.toString() ?? 'N/A'
                                : patient['age']?.toString() ?? 'N/A';

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Gender: $gender | Age: $age',
                                  style: GoogleFonts.poppins(),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.person),
                                      label: const Text("View Profile"),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        backgroundColor: Colors.blueAccent,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => PatientProfilePage(
                                                  patientId: patient['_id'],
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.article),
                                      label: const Text("View Report"),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => PatientReportsPage(
                                                  patientId: patient['_id'],
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
    );
  }
}
