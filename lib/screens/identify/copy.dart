// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter_vision/flutter_vision.dart';

// class YoloVideo extends StatefulWidget {
//   @override
//   _YoloVideoState createState() => _YoloVideoState();
// }

// class _YoloVideoState extends State<YoloVideo> {
//   late CameraController controller;
//   late FlutterVision vision;
//   late List<Map<String, dynamic>> yoloResults = []; // Initialize to an empty list
//   CameraImage? cameraImage;
//   bool isLoaded = false;
//   bool isDetecting = false;
// 1
//   @override
//   void initState() {
//     super.initState();
//     init();
//   }

//   init() async {
//     final cameras = await availableCameras();
//     controller = CameraController(cameras[0], ResolutionPreset.high);
//     await controller.initialize();
//     vision = FlutterVision();
//     await loadYoloModel();
//     startDetection(); // Start detection after loading the model
//     setState(() {
//       isLoaded = true;
//     });
//   }

//   Future<void> loadYoloModel() async {
//     await vision.loadYoloModel(
//       labels: 'assets/labels.txt',
//       modelPath: 'assets/yolov8m.tflite',
//       modelVersion: "yolov8",
//       numThreads: 1,
//       useGpu: true,
//     );
//   }

//   Future<void> startDetection() async {
//     setState(() {
//       isDetecting = true;
//     });
//     if (controller.value.isStreamingImages) {
//       return;
//     }
//     await controller.startImageStream((image) async {
//       if (isDetecting) {
//         cameraImage = image;
//         await yoloOnFrame(image); // Ensure this is awaited
//       }
//     });
//   }

//   Future<void> yoloOnFrame(CameraImage cameraImage) async {
//     final result = await vision.yoloOnFrame(
//       bytesList: cameraImage.planes.map((plane) => plane.bytes).toList(),
//       imageHeight: cameraImage.height,
//       imageWidth: cameraImage.width,
//       iouThreshold: 0.4,
//       confThreshold: 0.4,
//       classThreshold: 0.5,
//     );
//     if (result.isNotEmpty) {
//       setState(() {
//         yoloResults = result;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     vision.closeYoloModel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           CameraPreview(controller),
//           ...displayBoxesAroundRecognizedObjects(),
//         ],
//       ),
//     );
//   }

//   List<Widget> displayBoxesAroundRecognizedObjects() {
//     if (yoloResults.isEmpty) return [];
//     return yoloResults.map((result) {
//       final rect = result['rect']; // Assuming 'rect' contains bounding box coordinates
//       final label = result['label']; // Assuming 'label' contains the class label
//       final confidence = result['confidence']; // Assuming 'confidence' contains the confidence score

//       // Calculate bounding box positions
//       final left = rect['x'] * MediaQuery.of(context).size.width;
//       final top = rect['y'] * MediaQuery.of(context).size.height;
//       final width = rect['width'] * MediaQuery.of(context).size.width;
//       final height = rect['height'] * MediaQuery.of(context).size.height;

//       return Positioned(
//         left: left,
//         top: top,
//         child: Container(
//           width: width,
//           height: height,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.red, width: 2),
//           ),
//           child: Text(
//             '$label: ${confidence.toStringAsFixed(2)}',
//             style: TextStyle(color: Colors.red, backgroundColor: Colors.white),
//           ),
//         ),
//       );
//     }).toList();
//   }
// }







// modify code for saving images. instead of saving the image_path of an image to the image_meta_Data, save the actual image into the localdatabase by storing the actual image to the "image_path" of image_meta_Data:


// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:tflite/tflite.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:zingexpo/database/database.dart';
// import 'package:zingexpo/database/database_helper.dart';
// import 'package:zingexpo/screens/BottomNavigationBars/bottomnavbarsample.dart'; // Ensure this path is correct

// class ImageIdentify extends StatefulWidget {
//   final int quadratID;
//   final int projectID;
//   final Map<String, dynamic> allData;

//   const ImageIdentify({
//     super.key,
//     required this.quadratID,
//     required this.projectID,
//     required this.allData,
//   });

//   @override
//   State<ImageIdentify> createState() => _ImageIdentifyState();
// }

// class _ImageIdentifyState extends State<ImageIdentify> {
//   List<Map<String, dynamic>> allData = [];

//   bool _isLoading = true;
//   bool isLoading = true;

//   String output = '';
//   String? imagePath; // To store the path of the selected image
//   double? latitude;
//   double? longitude;
//   double? elevation; // Add elevation variable
//   Future<void> _loadData() async {
//     try {
//       final data = await LocalDatabase().readData();
//       setState(() {
//         allData = data;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       // Handle error (show dialog, log, etc.)
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     loadModel();
//   }

//   Future<void> _fetchProjects() async {
//     final projectID =
//         widget.allData['project_id']; // Get the selected project ID

//     _loadData();

//     setState(() {
//       isLoading = false; // Loading done
//     });
//     _loadData();
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

//     try {
//       if (widget.projectID != null && widget.quadratID != null) {
//         await LocalDatabase().insertImageData({
//           'image_name': speciesName,
//           'image_path': imagePath,
//           'latitude': latitude ?? 0.0, // Use 0.0 if latitude is null
//           'longitude': longitude ?? 0.0, // Use 0.0 if longitude is null
//           'elevation': elevation ?? 0.0, // Use 0.0 if elevation is null
//           "project_id": widget.projectID,
//           "quadrat_id": widget.quadratID,
//           'capture_date': DateTime.now().toIso8601String(),
//         });

//         // Show a success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Species saved successfully!')),
//         );
//         Navigator.pop(context);
//         // Navigator.pushAndRemoveUntil(
//         //     context,
//         //     MaterialPageRoute(
//         //         builder: (context) => FloatingSample(
//         //               allData: widget.allData,
//         //               projectID: widget.projectID,
//         //               onDelete: () {
//         //                 _fetchProjects(); // Fetch the updated list
//         //               },
//         //             )),
//         //     (route) => false);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Project ID or Quadrat ID is missing.')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error saving species: $e')),
//       );
//     }
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
//                 onPressed: _saveIdentifiedSpecie,
//                 child: const Text('Save Identified Specie to Database'),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
