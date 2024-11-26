// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:tflite/tflite.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:zingexpo/database/database_helper.dart'; // Ensure this path is correct

// class ImageIdentify extends StatefulWidget {
//   const ImageIdentify({super.key});

//   @override
//   State<ImageIdentify> createState() => _ImageIdentifyState();
// }

// class _ImageIdentifyState extends State<ImageIdentify> {
//   String output = '';
//   String? imagePath; // To store the path of the selected image
//   double? latitude;
//   double? longitude;
//   double? elevation; // Add elevation variable

//   @override
//   void initState() {
//     super.initState();
//     loadModel();
//   }

//   Future<void> loadModel() async {
//     String? res = await Tflite.loadModel(
//       model: "assets/model.tflite",
//       labels: "assets/labels.txt",
//     );
//     print("Model loaded: $res");
//   }

//   Future<void> openGallery() async {
//     final ImagePicker _picker = ImagePicker();
//     final XFile? pickedFile =
//         await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       imagePath = pickedFile.path;
//       await classifyImage(File(imagePath!));
//       await _getCurrentLocation(); // Get current location
//     }
//   }

//   Future<void> openCamera() async {
//     final ImagePicker _picker = ImagePicker();
//     final XFile? pickedFile =
//         await _picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       imagePath = pickedFile.path;
//       await classifyImage(File(imagePath!));
//       await _getCurrentLocation(); // Get current location
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
//         // Clear previous output
//         output = '';

//         // Debug: Print the recognitions list
//         print("Recognitions: $recognitions");

//         // Check for the highest confidence label
//         if (recognitions.isNotEmpty) {
//           double highestConfidence =
//               recognitions[0]['confidence'] * 100; // Convert to percentage
//           String highestLabel = recognitions[0]['label'];
//           output += "$highestLabel - ${highestConfidence.toStringAsFixed(2)}%";

//           // If the highest confidence is less than 100%, show the next possible label
//           if (highestConfidence < 100 && recognitions.length > 1) {
//             double nextConfidence = recognitions[1]['confidence'] * 100;
//             String nextLabel = recognitions[1]['label'];
//             output +=
//                 "\nNext Possible: $nextLabel - ${nextConfidence.toStringAsFixed(2)}%";
//           } else {
//             output += "\nNo next possible identification available.";
//           }
//         }
//       });
//     }
//   }

//   Future<void> _getCurrentLocation() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     setState(() {
//       latitude = position.latitude;
//       longitude = position.longitude;
//       elevation = position.altitude; // Get elevation
//     });
//   }

//   Future<void> _saveIdentifiedSpecie() async {
//     // Always save the species name, default to "Unidentified" if no output
//     String speciesName =
//         output.isNotEmpty ? output.split(' - ').first : "Unidentified";

//     // Save the species data to the database
//     DatabaseHelper dbHelper = DatabaseHelper();
//     await dbHelper.insertImageData({
//       'image_name': speciesName,
//       'image_path': imagePath,
//       'latitude': latitude ?? 0.0, // Use 0.0 if latitude is null
//       'longitude': longitude ?? 0.0, // Use 0.0 if longitude is null
//       'elevation': elevation ?? 0.0, // Use 0.0 if elevation is null
//       'capture_date': DateTime.now().toIso8601String(),
//     });

//     // Show a success message
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Species saved successfully!')),
//     );
//   }

//   @override
//   void dispose() {
//     Tflite.close();
//     super.dispose();
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
//             const SizedBox(height: 20), // Add some space before the buttons

//             ElevatedButton(
//               onPressed: openGallery,
//               child: const Text('Select Image from Gallery'),
//             ),
//             ElevatedButton(
//               onPressed: openCamera,
//               child: const Text('Open Camera'),
//             ),
//             if (output.isNotEmpty)
//               ElevatedButton(
//                 onPressed: () {},
//                 child: const Text('Save Identified Specie to Database'),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
