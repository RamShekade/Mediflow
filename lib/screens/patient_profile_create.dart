import 'package:MediFlow/screens/user_home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProfileOnboarding extends StatefulWidget {
  final String userId;
  const UserProfileOnboarding({super.key, required this.userId});

  @override
  State<UserProfileOnboarding> createState() => _UserProfileOnboardingState();
}

class _UserProfileOnboardingState extends State<UserProfileOnboarding> {
  final PageController _pageController = PageController();
  int currentStep = 0;
  bool isLoading = false;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emergencyContactsController =
      TextEditingController();
  final TextEditingController medicationsController = TextEditingController();
  final TextEditingController conditionsController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController inviteCodeController = TextEditingController();

  String? selectedGender;
  DateTime? selectedDOB;

  final String baseUrl = 'http://192.168.1.5:5000/api';

  void nextStep() {
    if (currentStep < 2) {
      setState(() => currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      submitProfile();
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _selectDOB(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDOB = picked;
      });
    }
  }

  Future<void> submitProfile() async {
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        medicationsController.text.trim().isEmpty ||
        conditionsController.text.trim().isEmpty ||
        allergiesController.text.trim().isEmpty ||
        selectedGender == null ||
        selectedDOB == null) {
      showSnackBar("Please complete all required fields.");
      return;
    }

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('$baseUrl/patient/onboarding'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': widget.userId,
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'medications': medicationsController.text.trim(),
        'conditions': conditionsController.text.trim(),
        'allergies': allergiesController.text.trim(),
        'inviteCode': inviteCodeController.text.trim(),
        'emergencyContacts': emergencyContactsController.text.trim(),
        'sex': selectedGender,
        'dob': selectedDOB?.toIso8601String(),
      }),
    );

    setState(() => isLoading = false);

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => userHomePage()),
      );
    } else {
      showSnackBar("Failed: ${data['error'] ?? 'Unknown error'}");
    }
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.indigo,
      ),
    ),
  );

  Widget _buildStepContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        key: ValueKey(currentStep),
        padding: const EdgeInsets.only(top: 10),
        child: ListView(
          children: [
            if (currentStep == 0) ...[
              _sectionTitle("Step 1: Basic Info"),
              _buildTextField(firstNameController, "First Name", Icons.person),
              _buildTextField(
                lastNameController,
                "Last Name",
                Icons.person_outline,
              ),
              const SizedBox(height: 15),
              const Text("Select Gender"),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children:
                    ["Male", "Female", "Other"]
                        .map(
                          (gender) => ChoiceChip(
                            label: Text(gender),
                            selected: selectedGender == gender,
                            onSelected:
                                (_) => setState(() => selectedGender = gender),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 15),
              const Text("Date of Birth"),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDOB(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    selectedDOB != null
                        ? "${selectedDOB!.toLocal()}".split(' ')[0]
                        : "Select Date of Birth",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              _buildTextField(
                phoneController,
                "Phone Number",
                Icons.phone,
                inputType: TextInputType.phone,
              ),
            ] else if (currentStep == 1) ...[
              _sectionTitle("Step 2: Medical Info"),
              _buildTextField(
                medicationsController,
                "Medications",
                Icons.medication,
              ),
              _buildTextField(
                conditionsController,
                "Known Conditions",
                Icons.sick,
              ),
              _buildTextField(allergiesController, "Allergies", Icons.warning),
            ] else if (currentStep == 2) ...[
              _sectionTitle("Step 3: Emergency & Referral"),
              _buildTextField(
                inviteCodeController,
                "Doctor Invite Code",
                Icons.code,
              ),
              _buildTextField(
                emergencyContactsController,
                "Emergency Contacts",
                Icons.contact_phone,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType inputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Onboarding"),
        leading:
            currentStep > 0
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: prevStep,
                )
                : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (_, __) => _buildStepContent(),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                  icon: Icon(
                    currentStep < 2 ? Icons.navigate_next : Icons.check,
                  ),
                  label: Text(currentStep < 2 ? "Next" : "Submit"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: Colors.indigo,
                  ),
                  onPressed: nextStep,
                ),
      ),
    );
  }
}
