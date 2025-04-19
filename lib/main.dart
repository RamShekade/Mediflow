import 'package:MediFlow/screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:MediFlow/screens/login.dart';

void main() {
  runApp(
    MaterialApp(
      home: LoginPage(),
      debugShowCheckedModeBanner: false, // 👈 Removes the DEBUG banner
    ),
  );
}
