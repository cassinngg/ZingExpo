import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class FileAccessExample extends StatefulWidget {
  @override
  _FileAccessExampleState createState() => _FileAccessExampleState();
}

class _FileAccessExampleState extends State<FileAccessExample> {
  Future<void> _checkPermissions() async {
    // Check if the permission is granted
    var status = await Permission.storage.status;

    if (status.isDenied) {
      // Request permission
      if (await Permission.storage.request().isGranted) {
        // Permission granted
        print("Storage permission granted");
      } else {
        // Permission denied
        print("Storage permission denied");
      }
    } else if (status.isPermanentlyDenied) {
      // Permission denied forever, open app settings
      openAppSettings();
    } else {
      // Permission already granted
      print("Storage permission already granted");
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions(); // Check permissions on app start
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Access Example'),
      ),
      body: Center(
        child: Text('Check permissions for file access.'),
      ),
    );
  }
}
