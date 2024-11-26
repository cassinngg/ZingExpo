// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:zingexpo/database/database_helper.dart';
// import 'package:zingexpo/sample/sam.dart';

// class ImageMetaData extends StatefulWidget {
//   @override
//   _ImageMetaDataState createState() => _ImageMetaDataState();
// }

// class _ImageMetaDataState extends State<ImageMetaData> {
//   final ImagePicker _picker = ImagePicker();
//   late File _imageFile;

//   Future<void> _captureImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       final imagePath = await _saveImage(File(pickedFile.path));
//       final position = await _getPosition();

//       // Save data to the database
//       DatabaseHelper dbHelper = DatabaseHelper();
//       await dbHelper.insertImageData({
//         'image_name': pickedFile.name,
//         'image_path': imagePath,
//         'latitude': position.latitude.toString(),
//         'longitude': position.longitude.toString(),
//         'elevation': position.altitude.toString(),
//         'capture_date': DateTime.now().toIso8601String(),
//       });

//       // Navigate to the list screen after saving
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => ImageListScreen()),
//       );
//     }
//   }

//   Future<String> _saveImage(File image) async {
//     final directory = await getApplicationDocumentsDirectory();
//     final path = '${directory.path}/assets';
//     final imagePath = '$path/${DateTime.now().millisecondsSinceEpoch}.png';
//     await Directory(path).create(recursive: true);
//     final savedImage = await image.copy(imagePath);
//     return savedImage.path;
//   }

//   Future<Position> _getPosition() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return Future.error('Location permissions are permanently denied.');
//     }

//     return await Geolocator.getCurrentPosition();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Capture Image')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: _captureImage,
//           child: Text('Capture Image'),
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';
import 'dart:typed_data'; // Import for Uint8List
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:native_exif/native_exif.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class ImageCaptureScreen extends StatefulWidget {
  @override
  _ImageCaptureScreenState createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  File? _image;

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double elevation = position.altitude;
      await _saveImageWithMetadata(
          File(pickedFile!.path), position, elevation, context);
    }
  }

  // Future<void> _saveImageWithMetadata(
  //     File imageFile, Position position, double elevation) async {
  //   try {
  //     if (imageFile == null || position == null || elevation == null) {
  //       // Handle invalid image file, position or elevation
  //       return;
  //     }

  //     final bytes = await imageFile.readAsBytes();
  //     final directory = await getApplicationDocumentsDirectory();
  //     final newImagePath = path.join(directory.path, 'image_with_metadata.jpg');

  //     const int gpsConversionFactor = 10000000; // Corrected conversion factor
  //     final Map<String, IfdTag> tags = {
  //       'GPSLatitude': IfdTag.Rational([
  //         BigInt.from((position.latitude * gpsConversionFactor).round()),
  //         BigInt.from(gpsConversionFactor)
  //       ]),
  //       'GPSLongitude': IfdTag.Rational([
  //         BigInt.from((position.longitude * gpsConversionFactor).round()),
  //         BigInt.from(gpsConversionFactor)
  //       ]),
  //       'GPSAltitude':
  //           IfdTag.Rational([BigInt.from(elevation.round()), BigInt.from(1)]),
  //     };

  //     final imageWithExif = await writeExifData(bytes, tags);

  //     await File(newImagePath).writeAsBytes(imageWithExif);

  //     setState(() {
  //       _image = File(newImagePath);
  //     });

  //     // Ensure the context is valid for showing SnackBar
  //     if (context != null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Image saved with metadata!')));
  //     }
  //   } catch (e) {
  //     // Ensure the context is valid for showing SnackBar
  //     if (context != null) {
  //       ScaffoldMessenger.of(context)
  //           .showSnackBar(SnackBar(content: Text('Failed to save image: $e')));
  //     }
  //   }
  // }

  Future<void> _saveImageWithMetadata(File imageFile, Position position,
      double elevation, BuildContext context) async {
    try {
      if (imageFile == null || position == null || elevation == null) {
        // Handle invalid image file, position or elevation
        return;
      }

      // Read the image bytes
      final bytes = await imageFile.readAsBytes();
      final directory = await getApplicationDocumentsDirectory();
      final newImagePath = path.join(directory.path, 'image_with_metadata.jpg');

      // Create an instance of Exif
      final exif = await Exif.fromPath(imageFile.path);

      // Prepare the GPS metadata
      const int gpsConversionFactor = 10000000; // Corrected conversion factor
      final Map<String, Object> tags = {
        'GPSLatitude':
            (position.latitude * gpsConversionFactor).round().toString(),
        'GPSLatitudeRef': position.latitude >= 0 ? 'N' : 'S',
        'GPSLongitude':
            (position.longitude * gpsConversionFactor).round().toString(),
        'GPSLongitudeRef': position.longitude >= 0 ? 'E' : 'W',
        'GPSAltitude': elevation.toString(),
        'GPSAltitudeRef': '0', // 0 for sea level
      };

      // Write the EXIF data
      await exif.writeAttributes(tags);

      // Save the image with the new EXIF data
      await File(newImagePath).writeAsBytes(bytes);

      // Close the Exif instance
      await exif.close();

      // Optionally update the UI or state
      setState(() {
        _image = File(newImagePath);
      });

      // Show success message
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image saved with metadata!')));
      }
    } catch (e) {
      // Show error message
      if (context != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save image: $e')));
      }
    }
  }

  // Future<Uint8List> writeExifData(
  //     List<int> imageBytes, Map<String, IfdTag> tags) async {
  //   final img.Image image = img
  //       .decodeImage(Uint8List.fromList(imageBytes))!; // Convert to Uint8List
  //   final newImageBytes = img.encodeJpg(image, quality: 100);

  //   // Placeholder for writing EXIF data
  //   // You would typically use a library to write the EXIF data into the new image bytes.
  //   return Uint8List.fromList(newImageBytes); // Ensure this returns Uint8List
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Capture Image with Metadata')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null) Image.file(_image!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _captureImage,
              child: const Text('Capture Image'),
            ),
          ],
        ),
      ),
    );
  }
}
