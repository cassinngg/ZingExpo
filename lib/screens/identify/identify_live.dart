import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageIdentify extends StatefulWidget {
  const ImageIdentify({Key? key}) : super(key: key);

  @override
  State<ImageIdentify> createState() => _ImageIdentifyState();
}

class _ImageIdentifyState extends State<ImageIdentify> {
  String output = '';
  String? imagePath; // To store the path of the selected image
  bool _isBusy = false; // Flag to prevent concurrent model runs

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    String? res = await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
    print("Model loaded: $res");
  }

  Future<void> openGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imagePath = pickedFile.path;
      await classifyImage(File(imagePath!));
    }
  }

  Future<void> classifyImage(File image) async {
    if (_isBusy) {
      print("Interpreter is busy. Please wait...");
      return; // Prevent concurrent calls
    }

    setState(() {
      _isBusy = true; // Set the busy flag
    });

    try {
      var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.1,
        numResults: 2,
      );

      if (recognitions != null) {
        setState(() {
          // Clear previous output
          output = '';

          // Debug: Print the recognitions list
          print("Recognitions: $recognitions");

          // Check for the highest confidence label
          if (recognitions.isNotEmpty) {
            double highestConfidence =
                recognitions[0]['confidence'] * 100; // Convert to percentage
            String highestLabel = recognitions[0]['label'];
            output +=
                "$highestLabel - ${highestConfidence.toStringAsFixed(2)}%";

            // If the highest confidence is less than 100%, show the next possible label
            if (highestConfidence < 100 && recognitions.length > 1) {
              double nextConfidence = recognitions[1]['confidence'] * 100;
              String nextLabel = recognitions[1]['label'];
              output +=
                  "\nNext Possible: $nextLabel - ${nextConfidence.toStringAsFixed(2)}%";
            } else {
              output += "\nNo next possible identification available.";
            }
          }
        });
      }
    } catch (e) {
      print("Error classifying image: $e");
    } finally {
      setState(() {
        _isBusy = false; // Reset the busy flag
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Zingiberaceae Flower Identification"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: imagePath != null
                ? Image.file(File(imagePath!))
                : Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey[300],
                    child: const Center(child: Text('No image selected.')),
                  ),
          ),
          Text(
            output.isNotEmpty ? output : "No result yet",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 20), // Add some space before the button
          ElevatedButton(
            onPressed: _isBusy ? null : openGallery, // Disable button if busy
            child: const Text('Select Image from Gallery'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
