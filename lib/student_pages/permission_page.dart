import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PermissionPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  PermissionPage({Key? key, this.userData}) : super(key: key);

  @override
  _PermissionPageState createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  late int studentId;
  bool _isLoading = false;

  final TextEditingController verificationCodeController =
      TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    studentId = widget.userData?['id'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Permission Request',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: verificationCodeController,
              decoration: InputDecoration(
                labelText: 'Verification Code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle permission request submission
                sendPermissionRequest();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(
                      'Verify',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendPermissionRequest() async {
    setState(() {
      _isLoading = true;
    });

    final apiUrl =
        'https://ams-production-7b32.up.railway.app/api/permission/$studentId/';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'verificationcode': verificationCodeController.text.trim(),
          'message': messageController.text.toString(),
        },
      );

      if (response.statusCode == 202) {
        final responseData = json.decode(response.body);
        // Permission request successful
        // You can handle the response or navigate to another screen
        print('Permission request successful');
        print(responseData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permission sent'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        verificationCodeController.clear();
        messageController.clear();
      } else {
        // Handle other status codes or errors
        print('Permission request denied');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send permission, please try again'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Handle network or other errors
      print('Error: $e');
      print('Permission request denied');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network issues, check and try again'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }
}
