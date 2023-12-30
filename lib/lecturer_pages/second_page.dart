import 'package:ams_mobile/lecturer_pages/generate_code.dart';
import 'package:ams_mobile/lecturer_pages/lecturer_home_page.dart';
import 'package:ams_mobile/lecturer_pages/chatpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  var _selectedIndex = 0;
  late Future<Map<String, dynamic>> userData;
  late int userId;

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
        'https://ams-production-7b32.up.railway.app/api/generateCode/$userId/');
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
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final userData = snapshot.data;

            // Pass user data down to the pages
            return _pages[_selectedIndex](userData!);
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateButtonBar,
        selectedItemColor: Colors.green,
        items: const [
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
    );
  }

  final List<Widget Function(Map<String, dynamic>)> _pages = [
    (userData) => LecturerHome(userData: userData),
    (userData) => GeneratePage(userData: userData),
    (userData) => PermissionTable(userData: userData),
  ];
}
