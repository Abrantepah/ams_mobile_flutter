import 'package:flutter/material.dart';
import 'package:ams_mobile/lecturer_pages/second_page.dart';
import 'package:ams_mobile/start_pages/login_page.dart';
import 'package:ams_mobile/student_pages/attendance_page.dart';
import 'package:ams_mobile/student_pages/testingpage.dart';
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
      home: MainApp(), // Display the splash screen initially
      routes: {
        '/firstpage': (context) => FirstPage(),
        '/secondpage': (context) => SecondPage(),
        '/attendancepage': (context) => AttendancePage(),
        '/redirectpage': (context) => Redirect(),
      },
    );
  }
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool doubleBackToExit = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (doubleBackToExit) {
          // Exit the app
          return true;
        } else {
          // Show a message
          setState(() {
            doubleBackToExit = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );

          // Reset the flag after 2 seconds
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              doubleBackToExit = false;
            });
          });

          // Return false to prevent the default back navigation
          return false;
        }
      },
      child: LoginPage(),
    );
  }
}
