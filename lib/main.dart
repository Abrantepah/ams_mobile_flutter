import 'package:ams_mobile/lecturer_pages/second_page.dart';
import 'package:ams_mobile/student_pages/attendance_page.dart';
import 'package:ams_mobile/student_pages/testingpage.dart';
import 'package:flutter/material.dart';
import 'package:ams_mobile/start_pages/login_page.dart';
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
      home: SplashScreen(), // Display the splash screen initially
      routes: {
        '/firstpage': (context) => FirstPage(),
        '/secondpage': (context) => SecondPage(),
        '/attendancepage': (context) => AttendancePage(),
        '/redirectpage': (context) => Redirect(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a long-running task, such as loading data or initializing resources
    Future.delayed(Duration(seconds: 3), () {
      // Navigate to the login page or the desired screen after the splash screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.green, // Set the background color of the splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your logo or any other image for the splash screen
            Image.asset(
              'lib/asset/logo.png', // Replace with the path to your image
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20),
            Text(
              'Your App Name',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
