import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zingexpo/database/database_helper.dart';
import 'package:zingexpo/sample/sam.dart';

class ImageMetaData extends StatefulWidget {
  @override
  _ImageMetaDataState createState() => _ImageMetaDataState();
}

class _ImageMetaDataState extends State<ImageMetaData> {
  final ImagePicker _picker = ImagePicker();
  late File _imageFile;

  Future<void> _captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final imagePath = await _saveImage(File(pickedFile.path));
      final position = await _getPosition();

      // Save data to the database
      DatabaseHelper dbHelper = DatabaseHelper();
      await dbHelper.insertImageData({
        'image_name': pickedFile.name,
        'image_path': imagePath,
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
        'elevation': position.altitude.toString(),
        'capture_date': DateTime.now().toIso8601String(),
      });

      // Navigate to the list screen after saving
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ImageListScreen()),
      );
    }
  }

  Future<String> _saveImage(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/assets';
    final imagePath = '$path/${DateTime.now().millisecondsSinceEpoch}.png';
    await Directory(path).create(recursive: true);
    final savedImage = await image.copy(imagePath);
    return savedImage.path;
  }

  Future<Position> _getPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Capture Image')),
      body: Center(
        child: ElevatedButton(
          onPressed: _captureImage,
          child: Text('Capture Image'),
        ),
      ),
    );
  }
}
