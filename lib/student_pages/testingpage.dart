import 'package:flutter/material.dart';

class Redirect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Extract the arguments passed by Navigator
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Access the studentId and verificationCode
    int studentId = arguments['studentId'];
    String verificationCode = arguments['verificationCode'];

    return Scaffold(
      body: Center(
        child: Text(
            "Student ID: $studentId\nVerification Code: $verificationCode"),
      ),
    );
  }
}
