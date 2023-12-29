import 'package:ams_mobile/lecturer_pages/second_page.dart';
import 'package:ams_mobile/start_pages/login_page.dart';
import 'package:ams_mobile/student_pages/attendance_page.dart';
import 'package:ams_mobile/student_pages/testingpage.dart';
import 'package:flutter/material.dart';
import 'package:ams_mobile/student_pages/first_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // Display the splash screen initially
      routes: {
        '/firstpage': (context) => FirstPage(),
        '/secondpage': (context) => SecondPage(),
        '/attendancepage': (context) => AttendancePage(),
        '/redirectpage': (context) => Redirect(),
      },
    );
  }
}
