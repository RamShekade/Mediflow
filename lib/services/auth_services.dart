import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final String baseUrl = "http://<your-ip>:5000/api/auth";

  Future<void> signupWithEmail(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('Signed up: ${data['user']['name']}');
    } else {
      print('Signup failed: ${response.body}');
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Logged in: ${data['user']['name']}');
    } else {
      print('Login failed: ${response.body}');
    }
  }

  Future<void> googleSignIn(String idToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/google-login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"idToken": idToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Google Login Success: ${data['user']['name']}');
    } else {
      print('Google login failed: ${response.body}');
    }
  }
}
