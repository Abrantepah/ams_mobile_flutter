import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLecturer = false;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  late String uuidCode;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });
    String userType = isLecturer ? 'lecturer' : 'student';
    final apiUrl =
        'https://ams-production-7b32.up.railway.app/api/$userType-login/';

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUUID = prefs.getString('uuid');

      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'username': usernameController.text.trim(),
          'password': passwordController.text.trim(),
          'uuidcode':
              storedUUID ?? '', // Use an empty string if storedUUID is null
        },
      );

      print('stored UUID: $storedUUID');

      if (response.statusCode == 200 && userType == 'student') {
        final responseData = json.decode(response.body);

        print('response data: $responseData');
        // Store or retrieve UUID using shared preferences
        if (storedUUID == null) {
          // Store UUID if not already stored
          prefs.setString('uuid', responseData['UUID']);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login successful'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushNamed(context, '/firstpage',
            arguments: responseData['id']);
      } else if (response.statusCode == 200 && userType == 'lecturer') {
        final responseData = json.decode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login successful'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushNamed(context, '/secondpage',
            arguments: responseData['id']);
      } else {
        final responseData = json.decode(response.body);

        print(
            'UUID mismatched. use your own device to login, Stored UUID: $storedUUID');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed. $responseData'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      print('Error during login: $error');
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Login',
              style: TextStyle(
                fontSize: 36.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 24.0),
            NeumorphicTextField(
              label: 'Username',
              icon: Icons.person,
              controller: usernameController,
            ),
            SizedBox(height: 16.0),
            NeumorphicTextField(
              label: 'Password',
              icon: Icons.lock,
              isPassword: true,
              controller: passwordController,
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Login As Lecturer',
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                ),
                Switch(
                  value: isLecturer,
                  onChanged: (value) {
                    setState(() {
                      isLecturer = value;
                    });
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                primary: Colors.green,
                onPrimary: Colors.white,
              ),
              child: _isLoading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      'Login',
                      style: TextStyle(fontSize: 18.0),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class NeumorphicTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;

  const NeumorphicTextField({
    Key? key,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.black),
            prefixIcon: Icon(
              icon,
              color: Colors.black,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
