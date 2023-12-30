// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'GeneratedCodeWidget.dart'; // Import the utility widget
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

class GeneratePage extends StatefulWidget {
  @override
  _GeneratePageState createState() => _GeneratePageState();
  final Map<String, dynamic>? userData;

  const GeneratePage({super.key, this.userData});
}

class _GeneratePageState extends State<GeneratePage> {
  late int lecturerId;
  List<Course> courses = [];
  String generatedCode = '';
  bool isButtonDisabled = false;
  String? selectedCourseId;
  late String latitude;
  late String longitude;
  late String session = 'waiting....';
  bool _isLoading = false;
  bool isLoadingSessions = false;

  @override
  void initState() {
    super.initState();
    lecturerId = widget.userData?['lecturer']['id'] ?? 0;
    _determineLocation();
    Timer.periodic(Duration(seconds: 300), (timer) {
      _determineLocation();
    });
    fetchCourses();
  }

  // get the current location of the user
  Future<void> _determineLocation() async {
    setState(() {
      _isLoading = true;
    });
    try {
      Position position = await Geolocator.getCurrentPosition();
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
    } catch (e) {
      print('Error getting location: $e');
    }
    setState(() {
      _isLoading = false;
    });
  }

  // send the location to the api for the code to be generated
  Future<void> sendLocation() async {
    setState(() {
      _isLoading = true;
    });
    final apiUrl =
        'https://ams-production-7b32.up.railway.app/api/generateCode/$lecturerId/$selectedCourseId/';

    try {
      final response = await http.post(Uri.parse(apiUrl), body: {
        'latitude': latitude,
        'longitude': longitude,
      });

      print('latitude $latitude, longitude $longitude');
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        generatedCode = responseData['code'];
        print('generated code:  $generatedCode');
        setState(() {});
      } else {
        print('error sending location');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'could\'nt generate code. Please try again. ${response.statusCode}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error sending location: $e');
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchCourses() async {
    print('Lecturer: $lecturerId');
    final apiUrl =
        'https://ams-production-7b32.up.railway.app/api/generateCode/$lecturerId/';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> coursesData = responseData['courses'];
        setState(() {
          courses =
              coursesData.map((courses) => Course.fromJson(courses)).toList();
        });
      } else {
        print('Failed to fetch data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchSessions(String courseId) async {
    final apiUrl =
        'https://ams-production-7b32.up.railway.app/api/generateCode/$lecturerId/$courseId/';

    try {
      setState(() {
        isLoadingSessions = true;
      });

      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        session = responseData['session']['id'].toString();
      } else {
        print('Failed to fetch session');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoadingSessions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Updated session display
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: isLoadingSessions || _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.green,
                        ),
                      )
                    : Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Session',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              session,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedCourseId,
                onChanged: (value) {
                  setState(() {
                    selectedCourseId = value;
                    fetchSessions(selectedCourseId!);
                  });
                },
                items: courses
                    .map((course) => DropdownMenuItem(
                          value: course.id.toString(),
                          child: Text(course.name),
                        ))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Select Course',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: isButtonDisabled ? null : () => sendLocation(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Generate',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
              ),
              SizedBox(height: 20),
              if (generatedCode.isNotEmpty)
                GeneratedCodeWidget(generatedCode: generatedCode),
            ],
          ),
        ),
      ),
    );
  }
}

class Course {
  final int id;
  final String name;

  Course({required this.id, required this.name});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
    );
  }
}
