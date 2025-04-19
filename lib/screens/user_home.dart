import 'package:MediFlow/screens/patient_report.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:MediFlow/screens/appointment.dart';
import 'package:MediFlow/screens/previsit.dart';
import 'package:MediFlow/screens/login.dart'; // <- Import your login screen

class userHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<userHomePage> {
  String userName = '';
  String email = '';
  String userId = '';
  String profilePicUrl = 'https://example.com/profile.jpg';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? 'N/A';
      userName = prefs.getString('userName') ?? 'User';
      email = prefs.getString('email') ?? 'No Email';
      profilePicUrl =
          prefs.getString('profilePicUrl') ?? 'https://example.com/profile.jpg';
    });
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Direct widget
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Patient Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
                ],
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(profilePicUrl),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning, $userName 👋',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'You have 2 notifications',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () {
                      // Handle notifications
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return FeatureCard(index: index, userId: userId);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final int index;
  final String userId;

  FeatureCard({required this.index, required this.userId});

  @override
  Widget build(BuildContext context) {
    List<String> titles = [
      "Talk to Assistant",
      "Pre-Visit Check-In",
      "Therapy Overview",
      "My Doctor",
      "Health Records",
      "Appointments",
    ];
    List<IconData> icons = [
      Icons.chat,
      Icons.assignment,
      Icons.medical_services,
      Icons.person,
      Icons.folder,
      Icons.schedule,
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: InkWell(
        onTap: () {
          if (index == 5) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AppointmentSchedulingPage(userId: userId),
              ),
            );
          } else if (index == 1 || index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatBotPage(userId: userId),
              ),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PatientReportsPage(patientId: userId),
              ),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icons[index], size: 50, color: Colors.blueAccent),
            SizedBox(height: 10),
            Text(
              titles[index],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
