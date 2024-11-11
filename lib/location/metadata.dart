// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:native_exif/native_exif.dart';
// import 'dart:io';

// class ImageCaptureExample extends StatefulWidget {
//   @override
//   _ImageCaptureExampleState createState() => _ImageCaptureExampleState();
// }

// class _ImageCaptureExampleState extends State<ImageCaptureExample> {
//   final ImagePicker _picker = ImagePicker();

//   Future<void> captureImage() async {
//     // Capture image from camera
//     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       // Get current location
//       Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//       await saveImageWithMetadata(pickedFile.path, position.latitude, position.longitude);
//     }
//   }

//   Future<void> saveImageWithMetadata(String imagePath, double latitude, double longitude) async {
//     // Read the existing EXIF data
//     final exif = await Exif.fromPath(imagePath);

//     // Set GPS metadata
//     await exif.setAttribute('GPSLatitude', latitude.toString());
//     await exif.setAttribute('GPSLatitudeRef', latitude >= 0 ? 'N' : 'S');
//     await exif.setAttribute('GPSLongitude', longitude.toString());
//     await exif.setAttribute('GPSLongitudeRef', longitude >= 0 ? 'E' : 'W');

//     // Save the modified EXIF data back to the image
//     await exif.saveAttributes();

//     // Optionally, you can save the modified image to a new file
//     // Note: The native_exif package does not provide a direct method to save the image.
//     // You may need to copy the original image to a new location if you want to keep the original intact.
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Capture Image with Metadata')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: captureImage,
//           child: Text('Capture Image'),
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:native_exif/native_exif.dart';

class Sam extends StatefulWidget {
  const Sam({super.key});

  @override
  State<Sam> createState() => _SamState();
}

class _SamState extends State<Sam> {
  final picker = ImagePicker();
  XFile? pickedFile;
  Exif? exif;
  Map<String, Object>? attributes;
  DateTime? shootingDate;
  ExifLatLong? coordinates;

  @override
  void initState() {
    super.initState();
  }

  Future<void> showError(Object e) async {
    debugPrintStack(
        label: e.toString(), stackTrace: e is Error ? e.stackTrace : null);

    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(e.toString()),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location Services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permission are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location Services are permanently denied, we cannot request Location.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future getImage() async {
    pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return;
    }

    exif = await Exif.fromPath(pickedFile!.path);
    attributes = await exif!.getAttributes();
    shootingDate = await exif!.getOriginalDate();
    coordinates = await exif!.getLatLong();

    setState(() {});
  }

  Future closeImage() async {
    await exif?.close();
    shootingDate = null;
    attributes = {};
    exif = null;
    coordinates = null;

    setState(() {});
  }

  Future<void> updateGPSAttributes() async {
    try {
      // Get current location
      Position position = await getCurrentLocation();

      // Update GPS attributes
      await exif!.writeAttributes({
        'GPSLatitude': position.latitude.toString(),
        'GPSLatitudeRef': position.latitude >= 0 ? 'N' : 'S',
        'GPSLongitude': position.longitude.toString(),
        'GPSLongitudeRef': position.longitude >= 0 ? 'E' : 'W',
      });

      // Refresh attributes
      shootingDate = await exif!.getOriginalDate();
      attributes = await exif!.getAttributes();
      coordinates = await exif!.getLatLong();

      setState(() {});
    } catch (e) {
      showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pickedFile == null)
              const Text("Please open an image.")
            else
              Column(
                children: [
                  Text(
                      "The selected image has ${attributes?.length ?? 0} attributes."),
                  Text("It was taken at ${shootingDate.toString()}"),
                  Text(attributes?["User Comment"]?.toString() ?? ''),
                  Text("Attributes: $attributes"),
                  Text("Coordinates: $coordinates"),
                  TextButton(
                    onPressed: () async {
                      try {
                        final dateFormat = DateFormat('yyyy:MM:dd HH:mm:ss');
                        await exif!.writeAttribute('DateTimeOriginal',
                            dateFormat.format(DateTime.now()));

                        shootingDate = await exif!.getOriginalDate();
                        attributes = await exif!.getAttributes();

                        setState(() {});
                      } catch (e) {
                        showError(e);
                      }
                    },
                    child: const Text('Update date attribute'),
                  ),
                  TextButton(
                    onPressed: updateGPSAttributes, // Call the new method
                    child: const Text('Update GPS attributes'),
                  ),
                  ElevatedButton(
                    onPressed: closeImage,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red)),
                    child: const Text('Close image'),
                  )
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: getImage,
              child: const Text('Open image'),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';

// import 'package:native_exif/native_exif.dart';

// class sam extends StatefulWidget {
//   const sam({
//     super.key,
//   });

//   @override
//   State<sam> createState() => _samState();
// }

// class _samState extends State<sam> {
//   final picker = ImagePicker();

//   XFile? pickedFile;
//   Exif? exif;
//   Map<String, Object>? attributes;
//   DateTime? shootingDate;
//   ExifLatLong? coordinates;

//   @override
//   void initState() {
//     super.initState();
//   }

//   Future<void> showError(Object e) async {
//     debugPrintStack(
//         label: e.toString(), stackTrace: e is Error ? e.stackTrace : null);

//     return showDialog<void>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Error'),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: [
//                 Text(e.toString()),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future getImage() async {
//     pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile == null) {
//       return;
//     }

//     exif = await Exif.fromPath(pickedFile!.path);
//     attributes = await exif!.getAttributes();
//     shootingDate = await exif!.getOriginalDate();
//     coordinates = await exif!.getLatLong();

//     setState(() {});
//   }

//   Future closeImage() async {
//     await exif?.close();
//     shootingDate = null;
//     attributes = {};
//     exif = null;
//     coordinates = null;

//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Plugin example app'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (pickedFile == null)
//               const Text("Please open an image.")
//             else
//               Column(
//                 children: [
//                   Text(
//                       "The selected image has ${attributes?.length ?? 0} attributes."),
//                   Text("It was taken at ${shootingDate.toString()}"),
//                   Text(attributes?["UserComment"]?.toString() ?? ''),
//                   Text("Attributes: $attributes"),
//                   Text("Coordinates: $coordinates"),
//                   TextButton(
//                     onPressed: () async {
//                       try {
//                         final dateFormat = DateFormat('yyyy:MM:dd HH:mm:ss');
//                         await exif!.writeAttribute('DateTimeOriginal',
//                             dateFormat.format(DateTime.now()));

//                         shootingDate = await exif!.getOriginalDate();
//                         attributes = await exif!.getAttributes();

//                         setState(() {});
//                       } catch (e) {
//                         showError(e);
//                       }
//                     },
//                     child: const Text('Update date attribute'),
//                   ),
//                   TextButton(
//                     onPressed: () async {
//                       try {
//                         // Get original attributes.
//                         final attrs = await exif!.getAttributes();

//                         debugPrint(
//                             'Original attributes of ${pickedFile!.path}:');
//                         debugPrint(attrs.toString());

//                         final dateFormat = DateFormat('yyyy:MM:dd HH:mm:ss');
//                         debugPrint(
//                             'Write DateTimeOriginal ${dateFormat.format(DateTime.now())}');
//                         await exif!.writeAttribute('DateTimeOriginal',
//                             dateFormat.format(DateTime.now()));

//                         await exif!.writeAttributes({
//                           'GPSLatitude': '1.0',
//                           'GPSLatitudeRef': 'N',
//                           'GPSLongitude': '2.0',
//                           'GPSLongitudeRef': 'W',
//                         });

//                         shootingDate = await exif!.getOriginalDate();
//                         attributes = await exif!.getAttributes();

//                         debugPrint('New attributes:');
//                         debugPrint(shootingDate.toString());
//                         debugPrint(attributes.toString());

//                         final dir = await getApplicationDocumentsDirectory();
//                         final newPath =
//                             p.join(dir.path, p.basename(pickedFile!.path));

//                         debugPrint('New path:');
//                         debugPrint(newPath);

//                         final newFile = File(newPath);
//                         await newFile
//                             .writeAsBytes(await pickedFile!.readAsBytes());

//                         pickedFile = XFile(newPath);
//                         exif = await Exif.fromPath(newPath);
//                         attributes = await exif!.getAttributes();
//                         shootingDate = await exif!.getOriginalDate();
//                         coordinates = await exif!.getLatLong();

//                         debugPrint('Attributes of $newPath:');
//                         debugPrint(shootingDate.toString());
//                         debugPrint(coordinates.toString());
//                         debugPrint(attributes.toString());

//                         setState(() {});
//                       } catch (e) {
//                         showError(e);
//                       }
//                     },
//                     child: const Text('Update, store and reload attributes'),
//                   ),
//                   TextButton(
//                     onPressed: () async {
//                       try {
//                         await exif!.writeAttribute('Orientation', '1');

//                         attributes = await exif!.getAttributes();

//                         setState(() {});
//                       } catch (e) {
//                         showError(e);
//                       }
//                     },
//                     child: const Text('Set orientation to 1'),
//                   ),
//                   TextButton(
//                     onPressed: () async {
//                       try {
//                         await exif!.writeAttributes({
//                           'GPSLatitude': '1.0',
//                           'GPSLatitudeRef': 'N',
//                           'GPSLongitude': '2.0',
//                           'GPSLongitudeRef': 'W',
//                         });

//                         shootingDate = await exif!.getOriginalDate();
//                         attributes = await exif!.getAttributes();
//                         coordinates = await exif!.getLatLong();

//                         setState(() {});
//                       } catch (e) {
//                         showError(e);
//                       }
//                     },
//                     child: const Text('Update GPS attributes'),
//                   ),
//                   ElevatedButton(
//                     onPressed: closeImage,
//                     style: ButtonStyle(
//                         backgroundColor: MaterialStateProperty.all(Colors.red)),
//                     child: const Text('Close image'),
//                   )
//                 ],
//               ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: getImage,
//               child: const Text('Open image'),
//             ),
//             if (pickedFile != null)
//               ElevatedButton(
//                 onPressed: () async {
//                   try {
//                     final file = File(
//                         p.join(Directory.systemTemp.path, 'tempimage.jpg'));
//                     final imageBytes = await pickedFile!.readAsBytes();
//                     await file.create();
//                     await file.writeAsBytes(imageBytes);
//                     final _attributes = await exif?.getAttributes() ?? {};
//                     final newExif = await Exif.fromPath(file.path);

//                     _attributes['DateTimeOriginal'] = '2021:05:15 13:00:00';
//                     _attributes['UserComment'] = "This file is user generated!";

//                     await newExif.writeAttributes(_attributes);

//                     shootingDate = await newExif.getOriginalDate();
//                     attributes = await newExif.getAttributes();
//                     coordinates = await newExif.getLatLong();

//                     setState(() {});
//                   } catch (e) {
//                     showError(e);
//                   }
//                 },
//                 child: const Text("Create file and write exif data"),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
