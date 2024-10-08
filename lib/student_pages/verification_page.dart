import 'package:ams_mobile/student_pages/attendance_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:async';

class VerificationPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const VerificationPage({super.key, this.userData});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  late int studentId;
  late TextEditingController _codeController;
  bool _isLoading = false;
  late String latitude;
  late String longitude;
  late String lecturer;
  late String session;
  late String course;

  @override
  void initState() {
    super.initState();
    studentId = widget.userData?['id'] ?? 0;
    _codeController = TextEditingController();
    _determinePosition();
    Timer.periodic(const Duration(seconds: 300), (timer) {
      _determinePosition();
    });
  }

  Future<void> verify(String verificationCode) async {
    setState(() {
      _isLoading = true; // Set loading to true before making the request
    });
    print('code: $verificationCode');
    print("latitude: $latitude Longitude: $longitude");
    print(studentId);
    final apiUrl =
        'https://ams-production-7b32.up.railway.app/api/verification_api/$studentId/';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'verificationcode': verificationCode,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.statusCode == 202) {
        final responseData = json.decode(response.body);

        setState(() {
          lecturer = responseData['lecturer']['name'];
          session = responseData['session']['id'].toString();
          course = responseData['courses']['name'];
        });

        final verifyResponse = {
          'studentId': studentId,
          'verificationCode': verificationCode,
          'lecturer': lecturer,
          'session': session,
          'course': course,
        };

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AttendancePage(verifyResponse: verifyResponse),
          ),
        );
      } else {
        final responseData = json.decode(response.body);
        // Handle error
        print('$responseData Status code: ${response.statusCode}');
        // Display an error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$responseData. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Handle network or other errors
      print('Error: $e');
      // Display an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      // Set loading to false after the request is complete
      setState(() {
        _isLoading = false;
      });
    }
  }

  // get the current location of the user
  Future<void> _determinePosition() async {
  setState(() {
    _isLoading = true;
  });

  try {
     LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    // Permissions are denied or denied forever, let's request it!
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("Location permissions are still denied");
    } else if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied");
    } else {
      // Permissions are granted (either can be whileInUse, always, restricted).
      Position position = await Geolocator.getCurrentPosition();
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
       print("Location permissions are granted after requesting");
    }
  }
   } catch (e) {
    print('Error getting location: $e');
   }

  setState(() {
    _isLoading = false;
  });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter Verification Code',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Enter code',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        verify(_codeController.text.trim());
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green[500],
                        padding: const EdgeInsets.all(17),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Verify',
                              style: TextStyle(fontSize: 20),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
