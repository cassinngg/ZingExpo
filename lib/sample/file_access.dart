import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

import 'package:zingexpo/database/database.dart';

class ProjectShareExample extends StatelessWidget {
  final Map<String, dynamic> projectData; // Project details
  final int projectID;

  const ProjectShareExample({
    super.key,
    required this.projectData,
    required this.projectID,
  });

  Future<void> requestPermissions(BuildContext context) async {
    var status = await Permission.storage.request();

    if (status.isGranted) {
      await _shareProject(context);
    } else if (status.isDenied) {
      _showPermissionDeniedDialog(context);
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _shareProject(BuildContext context) async {
    final directory = await getApplicationDocumentsDirectory();
    final projectFolderName = 'Project_$projectID';
    final projectFolder = Directory('${directory.path}/$projectFolderName');

    if (!await projectFolder.exists()) {
      await projectFolder.create(recursive: true);
    }

    // Save project details
    final projectFilePath = '${projectFolder.path}/project_details.json';
    final projectFile = File(projectFilePath);
    await projectFile.writeAsString(jsonEncode(projectData));

    // Fetch quadrats from the database
    final localDatabase = LocalDatabase();
    List<Map<String, Object?>> quadrats =
        await localDatabase.getQuadratsByProjectID(projectID);

    // Save each quadrat's data
    for (int i = 0; i < quadrats.length; i++) {
      final quadrat = quadrats[i];
      final quadratFilePath = '${projectFolder.path}/quadrat_${i + 1}.json';
      final quadratFile = File(quadratFilePath);
      await quadratFile.writeAsString(jsonEncode(quadrat));
    }

    // Share the project folder
    await Share.shareFiles(
      [projectFolder.path],
      text: 'Check out my project with quadrat data!',
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Denied'),
          content:
              Text('File sharing cannot be done without storage permissions.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share Project Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => requestPermissions(context),
          child: Text('Share Project'),
        ),
      ),
    );
  }
}
