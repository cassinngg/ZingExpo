import 'package:flutter/material.dart';

class RealtimeCamScreen extends StatelessWidget {
  const RealtimeCamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:zingexpo/pages/scan_controller.dart';

// class RealtimeCamScreen extends StatelessWidget {
//   const RealtimeCamScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('ilisi sad ni'),
//           actions: [
//             IconButton(
//                 onPressed: () {
//                   Navigator.of(context).pushReplacementNamed('/home');
//                 },
//                 icon: const Icon(Icons.logout))
//           ],
//         ),
//         body: Container(
//           height: double.infinity,
//           width: double.infinity,
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//               SizedBox(
//                 height: 300,
//                 width: 200,
//                 child: GetBuilder<ScanController>(
//                   init: ScanController(),
//                   builder: (controller) {
//                     return controller.isCameraInitialized.value
//                         ? CameraPreview(controller.cameraController)
//                         : const Center(
//                             child: Text('Initializing....'),
//                           );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 20),
//               GetBuilder<ScanController>(
//                 builder: (controller) {
//                   return Text(
//                     controller.handSignResult.value ?? 'No Flower detected',
//                     style: const TextStyle(fontSize: 20),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ));
//   }
// }
