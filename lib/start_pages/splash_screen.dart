import 'package:ams_mobile/start_pages/login_page.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a long-running task, such as loading data or initializing resources
    Future.delayed(const Duration(seconds: 2), () {
      // Navigate to the home screen or the desired screen after the splash screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
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
            const SizedBox(height: 20),
            const Text(
              'AMS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Idan_version',
              style: TextStyle(
                color: Colors.green[200],
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
