import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AttendancePage extends StatefulWidget {
  final Map<String, dynamic>? verifyResponse;

  const AttendancePage({super.key, this.verifyResponse});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late int studentId;
  late String verificationCode;
  late String lecturer;
  late String course;
  late String session;
  late bool attendanceMarkedStart = false;
  late double timeRemaining;

  bool _loadingStartButton = false;
  bool _loadingEndButton = false;

  @override
  void initState() {
    super.initState();
    studentId = widget.verifyResponse?['studentId'] ?? 0;
    verificationCode = widget.verifyResponse?['verificationCode'] ?? '';
    lecturer = widget.verifyResponse?['lecturer'] ?? '';
    course = widget.verifyResponse?['course'] ?? '';
    session = widget.verifyResponse?['session'] ?? '';

    // Fetch data when the page loads
    fetchData();
  }

  Future<void> fetchData() async {
    final apiUrl =
        'https://ams-production-7b32.up.railway.app/api/MarkAttendance/$studentId/$verificationCode/';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        setState(() {
          timeRemaining = responseData['time_remaining'];
          attendanceMarkedStart = responseData['attendance_marked_start'];
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> markAttendance(String attendanceType) async {
    final apiUrl =
        'https://ams-production-7b32.up.railway.app/api/MarkAttendance/$studentId/$verificationCode/';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'attendance_type': attendanceType,
        },
      );
      if (response.statusCode == 201) {
        print('Attendance marked successfully');
        fetchData();
        //redirect to homepage
        Navigator.pushNamed(context, '/firstpage', arguments: studentId);

        // Display an error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance marked successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('Failed to mark attendance: ${response.statusCode}');

        // Display an error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to mark attendance. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      // Display an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again later.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('lib/asset/logo.png'),
            ),
            const SizedBox(height: 20),
            Text(
              'Mark Attendance',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700]),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Text(
                    course,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Lecturer: $lecturer',
                    style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey[500]),
                  const SizedBox(height: 20),
                  Text('Session $session',
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: attendanceMarkedStart
                      ? null
                      : () async {
                          // Handle button press for Mark Start Attendance
                          setState(() {
                            _loadingStartButton = true;
                          });
                          await markAttendance('start');
                          setState(() {
                            _loadingStartButton = false;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: attendanceMarkedStart
                        ? Colors.grey[400]
                        : Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _loadingStartButton
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Start',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
                ElevatedButton(
                  onPressed: _loadingEndButton
                      ? null
                      : () async {
                          // Handle button press for Mark End Attendance
                          setState(() {
                            _loadingEndButton = true;
                          });
                          await markAttendance('end');
                          setState(() {
                            _loadingEndButton = false;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[500],
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _loadingEndButton
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'End',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
