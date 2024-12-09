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
//ANOTHER ONE
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

//MOST RECENT VERSION

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:tflite/tflite.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:zingexpo/database/database.dart';
// import 'package:zingexpo/screens/home.dart';
// import 'package:zingexpo/screens/identify/identify_live.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:native_exif/native_exif.dart';

// class ImageIdentify extends StatefulWidget {
//   const ImageIdentify({super.key});

//   @override
//   State<ImageIdentify> createState() => _ImageIdentifyState();
// }

// class _ImageIdentifyState extends State<ImageIdentify> {
//   CameraImage? cameraImage;
//   CameraController? cameraController;
//   String output = '';
//   String? imagePath;

//   @override
//   void initState() {
//     super.initState();
//     loadModel();
//     loadCamera();
//   }

//   Future<void> loadCameras() async {
//     try {
//       cameras = await availableCameras();
//       if (cameras.isNotEmpty) {
//         loadCamera();
//       } else {
//         print("No cameras available");
//       }
//     } catch (e) {
//       print("Error loading cameras: $e");
//     }
//   }

//   Future<void> runModel() async {
//     if (cameraImage != null) {
//       var predictions = await Tflite.runModelOnFrame(
//         bytesList: cameraImage!.planes.map((plane) {
//           return plane.bytes;
//         }).toList(),
//         imageHeight: cameraImage!.height,
//         imageWidth: cameraImage!.width,
//         imageMean: 127.5,
//         imageStd: 127.5,
//         rotation: 90,
//         numResults: 2,
//         threshold: 0.1,
//         asynch: true,
//       );

//       if (predictions != null) {
//         setState(() {
//           output = predictions.map((element) => element['label']).join(', ');
//         });
//       }
//     }
//   }

//   void loadCamera() {
//     cameraController = CameraController(cameras[0], ResolutionPreset.medium);
//     cameraController!.initialize().then((value) {
//       if (!mounted) {
//         return;
//       } else {
//         setState(() {
//           cameraController!.startImageStream((imageStream) {
//             cameraImage = imageStream;
//             runModel();
//           });
//         });
//       }
//     }).catchError((e) {
//       print("Error initializing camera: $e");
//     });
//   }

//   Future<void> loadModel() async {
//     String? res = await Tflite.loadModel(
//       model: "./assets/model.tflite",
//       labels: "./assets/labels.txt",
//     );
//   }

//   Future<void> openGallery() async {
//     final ImagePicker _picker = ImagePicker();
//     final XFile? pickedFile =
//         await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       imagePath = pickedFile.path;
//       await classifyImage(File(imagePath!));
//     }
//   }

//   Future<void> classifyImage(File image) async {
//     var recognitions = await Tflite.runModelOnImage(
//       path: image.path,
//       imageMean: 127.5,
//       imageStd: 127.5,
//       threshold: 0.1,
//       numResults: 2,
//     );

//     if (recognitions != null) {
//       setState(() {
//         output = '';
//         if (recognitions.isNotEmpty) {
//           double highestConfidence =
//               recognitions[0]['confidence'] * 100; // Convert to percentage
//           String highestLabel =
//               recognitions[0]['label']?.replaceFirst(RegExp(r'^\d+: '), '') ??
//                   'Unknown';

//           output += "$highestLabel - ${highestConfidence.toStringAsFixed(2)}%";

//           // Check if the confidence is above a certain threshold
//           if (highestConfidence > 70) {
//             // Show save button if species is identified with sufficient confidence
//             showSaveButton = true;
//           } else {
//             showSaveButton = false;
//           }
//         }
//       });
//     }
//   }

//   bool showSaveButton = false;

//   Future<void> saveIdentifiedSpecie() async {
//     // Get current location
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);

//     // Save to database logic here
//     await LocalDatabase().saveIdentifiedSpecie(
//       speciesName: output.split(' - ')[0], // Get the species name
//       imagePath: imagePath,
//       latitude: position.latitude,
//       longitude: position.longitude,
//     );

//     // Optionally, navigate to another screen or show a confirmation message
//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(
//         builder: (context) => const Home(),
//       ),
//       (route) => false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Zingiberaceae Flower Identification"),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: imagePath != null
//                   ? Image.file(File(imagePath!))
//                   : Container(
//                       height: MediaQuery.of(context).size.height * 0.7,
//                       width: MediaQuery.of(context).size.width,
//                       color: Colors.grey[300],
//                       child: const Center(child: Text('No image selected.')),
//                     ),
//             ),
//             Text(
//               output.isNotEmpty ? output : "No result yet",
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//                 fontSize: 20,
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: openGallery,
//               child: const Text('Select Image from Gallery'),
//             ),
//             const SizedBox(height: 20),
//             if (showSaveButton)
//               ElevatedButton(
//                 onPressed: saveIdentifiedSpecie,
//                 child: const Text('Save Identified Specie to Database'),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     Tflite.close();
//     super.dispose();
//   }
// }
