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