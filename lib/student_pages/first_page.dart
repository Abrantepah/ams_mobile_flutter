import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ams_mobile/student_pages/home_page.dart';
import 'package:ams_mobile/student_pages/permission_page.dart';
import 'package:ams_mobile/student_pages/verification_page.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  var _selectedIndex = 0;
  late Future<Map<String, dynamic>> userData;
  late int userId;
  bool doubleBackToExit = false;

  void _navigateButtonBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Extract the user ID from the arguments
    userId = ModalRoute.of(context)!.settings.arguments as int;

    // Fetch user data once when the FirstPage is initialized
    userData = fetchUserData(
        'https://ams-production-7b32.up.railway.app/api/student-home/$userId');
  }

  Future<Map<String, dynamic>> fetchUserData(String apiUrl) async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          // If not on the Home page, navigate to Home page
          setState(() {
            _selectedIndex = 0;
          });
          return false; // Do not exit the app
        } else if (doubleBackToExit) {
          // If already on Home page, exit the app
          return true;
        } else {
          // Show a message
          setState(() {
            doubleBackToExit = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Press back again to logout'),
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
      child: Scaffold(
        body: FutureBuilder<Map<String, dynamic>>(
          future: userData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final userData = snapshot.data;

              // Pass user data down to the pages
              return _pages[_selectedIndex](userData!);
            } else {
              return Center(child: Text('No data available'));
            }
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _navigateButtonBar,
          selectedItemColor: Colors.green,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.border_all_rounded),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Permission',
            ),
          ],
        ),
      ),
    );
  }

  final List<Widget Function(Map<String, dynamic>)> _pages = [
    (userData) => HomePage(userData: userData),
    (userData) => VerificationPage(userData: userData),
    (userData) => PermissionPage(userData: userData),
  ];
}
