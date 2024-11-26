// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tflite/tflite.dart';

// class RealtimeCamScreen extends StatefulWidget {
//   @override
//   State<RealtimeCamScreen> createState() => _RealtimeCamScreenState();
// }

// class _RealtimeCamScreenState extends State<RealtimeCamScreen> {
//   PickedFile? _image;
//   bool _loading = false;
//   List<dynamic>? _outputs;

//   loadModel() async {
//     await Tflite.loadModel(
//       model: "assets/model.tflite",
//       labels: "assets/labels.txt",
//     );
//   }

//   classifyImage(image) async {
//     var output = await Tflite.runModelOnImage(
//       path: image.path,
//       numResults: 2,
//       threshold: 0.5,
//       imageMean: 127.5,
//       imageStd: 127.5,
//     );
//     setState(() {
//       _loading = false;
// //Declare List _outputs in the class which will be used to show the classified classs name and confidence
//       _outputs = output;
//     });
//   }

//   final ImagePicker _picker = ImagePicker();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Image Classification'),
//         backgroundColor: Colors.purple,
//       ),
//       body: _loading
//           ? Container(
//               alignment: Alignment.center,
//               child: CircularProgressIndicator(),
//             )
//           : Container(
//               width: MediaQuery.of(context).size.width,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   _image == null ? Container() : Image.file(File(_image!.path)),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   _outputs != null
//                       ? Text(
//                           '${_outputs![0]["label"]}',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 20.0,
//                             background: Paint()..color = Colors.white,
//                           ),
//                         )
//                       : Container()
//                 ],
//               ),
//             ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _optiondialogbox,
//         backgroundColor: Colors.purple,
//         child: Icon(Icons.image),
//       ),
//     );
//   }

//   // camera method
//   Future<void> _optiondialogbox() {
//     return showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             backgroundColor: Colors.purple,
//             content: SingleChildScrollView(
//               child: ListBody(
//                 children: <Widget>[
//                   GestureDetector(
//                     child: Text(
//                       "Take a Picture",
//                       style: TextStyle(color: Colors.white, fontSize: 20.0),
//                     ),
//                     onTap: openCamera,
//                   ),
//                   Padding(padding: EdgeInsets.all(10.0)),
//                   GestureDetector(
//                     child: Text(
//                       "Select image ",
//                       style: TextStyle(color: Colors.white, fontSize: 20.0),
//                     ),
//                     onTap: openGallery,
//                   )
//                 ],
//               ),
//             ),
//           );
//         });
//   }

//   Future openCamera() async {
//     var picture = await _picker.getImage(source: ImageSource.camera);

//     setState(() {
//       _image = picture;
//     });
//     classifyImage(picture);
//   }

//   //camera method
//   Future openGallery() async {
//     var piture = await _picker.getImage(source: ImageSource.gallery);
//     setState(() {
//       _image = piture;
//     });
//     classifyImage(piture);
//   }
// }
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

final ImagePicker _picker = ImagePicker();

Future<void> loadModel() async {
  String? res = await Tflite.loadModel(
    model: "assets/model.tflite",
    labels: "assets/labels.txt",
  );
  print("Model loaded: $res");
}

class RealtimeCamScreen extends StatefulWidget {
  @override
  _RealtimeCamScreenState createState() => _RealtimeCamScreenState();
}

class _RealtimeCamScreenState extends State<RealtimeCamScreen> {
  String? _imagePath;
  String _resultText = "No result yet";

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  // Future<void> runModelOnImage(String imagePath) async {
  //   var recognitions = await Tflite.runModelOnImage(
  //     path: imagePath,
  //     imageMean: 127.5,
  //     imageStd: 127.5,
  //     threshold: 0.4,
  //     asynch: true,
  //   );

  //   String result = "No result";
  //   if (recognitions != null && recognitions.isNotEmpty) {
  //     result = recognitions.map((recog) {
  //       return "${recog['detectedClass']} - ${recog['confidence'].toStringAsFixed(2)}";
  //     }).join("\n");
  //   }

  //   setState(() {
  //     _resultText = result;
  //   });
  // }
  @override
  void dispose() {
    Tflite.close(); // Dispose of the model
    super.dispose();
  }

  bool _isProcessing = false; // Add this flag

  Future<void> runModelOnImage(String imagePath) async {
    if (_isProcessing) {
      print("Model is already processing another image.");
      return;
    }

    _isProcessing = true; // Set to true to block new requests

    try {
      var recognitions = await Tflite.runModelOnImage(
        path: imagePath,
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.4,
        asynch: true,
      );

      String result = "No result";
      if (recognitions != null && recognitions.isNotEmpty) {
        result = recognitions.map((recog) {
          return "${recog['detectedClass']} - ${recog['confidence'].toStringAsFixed(2)}";
        }).join("\n");
      }

      setState(() {
        _resultText = result;
      });
    } catch (e) {
      print("Error running model: $e");
      setState(() {
        _resultText = "Failed to process image.";
      });
    } finally {
      _isProcessing = false; // Reset the flag when done
    }
  }

  // Future<void> runModelOnImage(String imagePath) async {
  //   try {
  //     var recognitions = await Tflite.runModelOnImage(
  //       path: imagePath,
  //       imageMean: 127.5,
  //       imageStd: 127.5,
  //       threshold: 0.4,
  //       asynch: true,
  //     );

  //     String result = "No result";
  //     if (recognitions != null && recognitions.isNotEmpty) {
  //       result = recognitions.map((recog) {
  //         return "${recog['detectedClass']} - ${recog['confidence'].toStringAsFixed(2)}";
  //       }).join("\n");
  //     }

  //     setState(() {
  //       _resultText = result;
  //     });
  //   } catch (e) {
  //     print("Error running model: $e");
  //     setState(() {
  //       _resultText = "Failed to process image.";
  //     });
  //   }
  // }

  Future<void> openGallery() async {
    XFile? picture = await _picker.pickImage(source: ImageSource.gallery);
    if (picture != null) {
      setState(() {
        _imagePath = picture.path;
        _resultText = "Processing...";
      });
      await runModelOnImage(picture.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Ginger Flower Identifier')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _imagePath != null
                  ? Image.file(
                      File(_imagePath!),
                      height: 300,
                      width: 300,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 300,
                      width: 300,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                    ),
              const SizedBox(height: 20),
              Text(
                _resultText,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: openGallery,
                child: Text('Select Image from Gallery'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
