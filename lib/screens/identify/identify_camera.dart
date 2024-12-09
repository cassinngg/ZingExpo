import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/database/database_helper.dart';
import 'package:zingexpo/screens/SpeciesFound/specie_details.dart';
import 'package:zingexpo/screens/specific_project_Screens/specific_project_screen.dart';
import 'package:zingexpo/screens/bottom_sheets/save_imagetoDB.dart';

class ImageIdentify extends StatefulWidget {
  final int quadratID;
  final int projectID;
  final Map<String, dynamic> allData;

  const ImageIdentify({
    super.key,
    required this.quadratID,
    required this.projectID,
    required this.allData,
  });

  @override
  State<ImageIdentify> createState() => _ImageIdentifyState();
}

class _ImageIdentifyState extends State<ImageIdentify> {
  List<Map<String, dynamic>> allData = [];

  bool _isLoading = true;
  bool isLoading = true;

  String output = '';
  String nextResult = '';
  String speciesinfo = '';

  String secondResult = '';
  String? imagePath;
  double? latitude;
  double? longitude;
  double? elevation;
  Future<void> _loadData() async {
    try {
      final data = await LocalDatabase().readData();
      setState(() {
        allData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error (show dialog, log, etc.)
    }
  }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> _fetchProjects() async {
    final projectID = widget.allData['project_id'];

    _loadData();

    setState(() {
      isLoading = false; // Loading done
    });
    _loadData();
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
      await _getCurrentLocation();
    }
  }

  Future<void> openCamera() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      imagePath = pickedFile.path;
      await classifyImage(File(imagePath!));
      await _getCurrentLocation();
    }
  }

  Future<void> classifyImage(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 127.5,
      imageStd: 127.5,
      threshold: 0.1,
      numResults: 2,
    );

    if (recognitions != null) {
      setState(() {
        output = '';
        speciesinfo = '';
        nextResult = '';
        print("Recognitions: $recognitions");

        if (recognitions.isNotEmpty) {
          double highestConfidence = recognitions[0]['confidence'] * 100;
          String highestLabel = recognitions[0]['label'];
          output += "$highestLabel - ${highestConfidence.toStringAsFixed(2)}%";

          speciesinfo = output;

          if (highestConfidence < 100 && recognitions.length > 1) {
            double nextConfidence = recognitions[1]['confidence'] * 100;
            String nextLabel = recognitions[1]['label'];
            output +=
                "\nNext Possible: $nextLabel - ${nextConfidence.toStringAsFixed(2)}%";
            nextResult = "$nextLabel - ${nextConfidence.toStringAsFixed(2)}%";
          } else {
            output += "\nNo next possible identification available.";
          }
        }
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      elevation = position.altitude;
    });
  }

  void showAddQuadratBottomSheet(BuildContext context, Uint8List image) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SaveImageTodb(
          image: image,
          projectID: widget.projectID,
          quadratID: widget.quadratID,
          elevation: elevation,
          latitude: latitude,
          longitude: longitude,
          output: output,
          secondResult: nextResult,
          onAdd: () {
            _loadData();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Zingiberaceae Flower Identification"),
      ),
      body: SingleChildScrollView(
        child: Column(
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: openGallery,
              child: const Text('Select Image from Gallery'),
            ),
            ElevatedButton(
              onPressed: openCamera,
              child: const Text('Open Camera'),
            ),
            const SizedBox(
              height: 10,
            ),
            if (output == 'Unidentified')
              const Text('')
            else
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SpeciesDetails(speciesinfo: speciesinfo),
                      ),
                    );
                  },
                  child: const Text('See Species Information')),
            const SizedBox(
              height: 10,
            ),
            if (output.isNotEmpty)
              ElevatedButton(
                onPressed: () async {
                  final Uint8List imageBytes =
                      await File(imagePath!).readAsBytes();

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SaveImageTodb(
                                image: imageBytes,
                                projectID: widget.projectID,
                                quadratID: widget.quadratID,
                                elevation: elevation,
                                latitude: latitude,
                                longitude: longitude,
                                output: output,
                                secondResult: nextResult,
                                onAdd: () {
                                  _loadData();
                                },
                              )));
                },
                child: const Text('Save Identified Specie to Database'),
              ),
          ],
        ),
      ),
    );
  }
}
