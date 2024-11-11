// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_tflite/flutter_tflite.dart';
// import 'package:image_picker/image_picker.dart';

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
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img; // For image processing

class RealtimeCamScreen extends StatefulWidget {
  @override
  _RealtimeCamScreenState createState() => _RealtimeCamScreenState();
}

class _RealtimeCamScreenState extends State<RealtimeCamScreen> {
  late Interpreter _interpreter;
  String _result = "No result yet";
  File? _image;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('model.tflite');
    } catch (e) {
      print("Error loading model: $e");
    }
    // _interpreter = await Interpreter.fromAsset('model.tflite');
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _classifyImage(_image!);
    }
  }

  Future<void> _classifyImage(File image) async {
    // Load labels
    final labels = await _loadLabels('assets/labels.txt');

    // Preprocess the image
    var inputImage = _preprocessImage(image);

    // Create a buffer for the output
    var output = List.filled(labels.length, 0.0).reshape([1, labels.length]);

    // Run inference
    _interpreter.run(inputImage, output);

    // Get the result
    var resultIndex =
        output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));

    // Check if the result is below a certain threshold or not in the labels
    if (output[0][resultIndex] < 0.5) {
      // Adjust threshold as needed
      setState(() {
        _result = "Unidentified Ginger";
      });
    } else {
      setState(() {
        _result = labels[resultIndex];
      });
    }
  }

  Future<List<String>> _loadLabels(String path) async {
    final labelsFile = await File(path).readAsString();
    return labelsFile.split('\n');
  }

  List<List<double>> _preprocessImage(File image) {
    // Load the image and resize it to the required input size
    img.Image originalImage = img.decodeImage(image.readAsBytesSync())!;
    img.Image resizedImage = img.copyResize(originalImage,
        width: 224, height: 224); // Adjust size as needed

    // Normalize the image data
    List<double> input = [];
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        var pixel = resizedImage.getPixel(x, y);
        input.add((img.getRed(pixel) - 127.5) / 127.5); // Normalize to [-1, 1]
        input.add((img.getGreen(pixel) - 127.5) / 127.5);
        input.add((img.getBlue(pixel) - 127.5) / 127.5);
      }
    }

    // Reshape input to match model input shape
    return [input]; // Return as a list of lists
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Classifier'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image == null ? Text('No image selected.') : Image.file(_image!),
              SizedBox(height: 20),
              Text('Result: $_result'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image from Gallery'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
