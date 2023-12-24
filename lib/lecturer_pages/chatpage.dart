import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class PermissionTable extends StatefulWidget {
  @override
  _PermissionTableState createState() => _PermissionTableState();
  final Map<String, dynamic>? userData;

  PermissionTable({Key? key, this.userData}) : super(key: key);
}

class _PermissionTableState extends State<PermissionTable> {
  bool _isSearching = false;
  late int lecturerId;
  List<Permissions> permissions = [];

  @override
  void initState() {
    super.initState();
    lecturerId = widget.userData?['lecturer']['id'] ?? 0;
    fetchMessages();
    // Schedule the fetchMessages function to be called every 30 seconds
    Timer.periodic(Duration(seconds: 3), (timer) {
      fetchMessages();
    });
  }

  Future<void> fetchMessages() async {
    print('Lecturer: $lecturerId');
    final apiUrl =
        'https://ams-production-7b32.up.railway.app/api/PermissionTable_api/$lecturerId/';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        final List<dynamic> permissionData = responseData['studentpermissions'];
        setState(() {
          permissions =
              permissionData.map((json) => Permissions.fromJson(json)).toList();
        });
      } else {
        print('Failed to fetch data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> handleStatus(int permissionId, String messagestatus) async {
    print('permissionId: $permissionId');
    final apiUrl =
        'https://ams-production-7b32.up.railway.app/api/update_permission_api/$permissionId/$messagestatus/';

    try {
      final response = await http.post(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print('permission Updated');
      } else {
        print('Failed permission Updated');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green, // Customize the app bar color
        automaticallyImplyLeading: false, // Remove back arrow
        title: _isSearching ? _buildSearchField() : _buildTitle(),
        actions: _buildAppBarActions(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact List
            Expanded(
              child: ListView.separated(
                itemCount: permissions.length,
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    color: Colors.grey[300],
                    thickness: 1.0,
                  );
                },
                itemBuilder: (BuildContext context, int index) {
                  Permissions permission = permissions[index];
                  return Dismissible(
                    key: UniqueKey(),
                    background: _buildSwipeBackground(),
                    onDismissed: (direction) {
                      // Handle swipe dismiss
                      if (direction == DismissDirection.endToStart) {
                        // Handle accept
                        handleStatus(permission.id, 'true');
                      } else {
                        // Handle decline
                        handleStatus(permission.id, 'false');
                      }
                    },
                    child: ContactItem(
                      sender: permission.studentname,
                      index: permission.index.toString(),
                      onTap: () {
                        // Handle tap on the contact item
                        _showStudentDetails(context, permission.studentname,
                            permission.message, permission.id);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
          color: Colors.white,
        ),
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            // Handle search text changes
          },
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Permission Request', // Customize the app bar title
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearching = false;
            });
          },
        ),
      ];
    } else {
      return [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {
            // Handle more options button click
          },
        ),
      ];
    }
  }

  Widget _buildSwipeBackground() {
    return Container(
      color: Colors.grey[300],
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.thumb_down, color: Colors.red),
          Icon(Icons.thumb_up, color: Colors.green),
        ],
      ),
    );
  }

  void _showStudentDetails(BuildContext context, String studentName,
      String sMessage, int permissionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(studentName),
          content: Text(sMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                handleStatus(permissionId, 'true');
              },
              child: Text('Accept'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                handleStatus(permissionId, 'false');
              },
              child: Text('Reject'),
            ),
          ],
        );
      },
    );
  }
}

class ContactItem extends StatelessWidget {
  final String sender;
  final String index;
  final VoidCallback? onTap;

  const ContactItem({
    Key? key,
    required this.sender,
    required this.index,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.0,
              backgroundColor: Colors.green[300],
              // You can add user profile images here
              // child: Icon(Icons.person, color: Colors.white),
            ),
            SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sender,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                Text(
                  'Index: $index',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
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

class Permissions {
  int id;
  String studentname;
  int index;
  String message;
  String created;
  bool sent;
  int studentsession; // Adjust the type based on the actual type in the API response

  Permissions({
    required this.id,
    required this.studentname,
    required this.index,
    required this.message,
    required this.created,
    required this.sent,
    required this.studentsession,
  });

  factory Permissions.fromJson(Map<String, dynamic> json) {
    return Permissions(
      id: json['id'],
      studentname: json['studentname'],
      index: json['index'],
      message: json['message'],
      created: json['created'],
      sent: json['sent'],
      studentsession: json['studentsession'],
    );
  }
}
