import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/sample/sample2.dart';
import 'package:zingexpo/samples/add%20button.dart';
import 'package:zingexpo/screens/home.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:zingexpo/database/firestore_service.dart';

class sample1 extends StatefulWidget {
  @override
  State<sample1> createState() => _sample1State();
}

class _sample1State extends State<sample1> {
  File? _selectedImage;
  String imageUrl = '';
  List<Map<String, dynamic>> _allData = [];

  final TextEditingController project_nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _selectOrCaptureImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      } else {
        _selectedImage = null;
      }
    });
  }

  Future<void> _initDatabase() async {
    try {
      await LocalDatabase().database;
      print('Database initialized successfully');
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  Future<void> _loadData() async {
    final data = await LocalDatabase().readData();
    setState(() {
      _allData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Project'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    onPressed: pickImageFromGallery,
                    icon: const Icon(
                      Icons.photo,
                      color: Colors.green,
                      size: 30,
                    ),
                  ),
                  TextField(
                    controller: project_nameController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      fillColor: Color(0xFF023C0E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            10), // Adjust the radius as needed
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Species',
                      fillColor: Color(0xFF023C0E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            10), // Adjust the radius as needed
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: 'Quadrat',
                      fillColor: Color(0xFF023C0E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            10), // Adjust the radius as needed
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _selectOrCaptureImage,
                    child: Text('Select/Capture Image'),
                  ),
                  _selectedImage != null
                      ? Image.file(_selectedImage!)
                      : Text('No image selected'),
                  ElevatedButton(
                    onPressed: () async {
                      // final String title = titleController.text;
                      // final String species = speciesController.text;
                      // final String quadrat = quadratController.text;

                      if (project_nameController.text.isNotEmpty) {
                        await LocalDatabase().addProject(
                            project_name: project_nameController.text,
                            project_description: descriptionController.text,
                            project_location: locationController.text,
                            imageFile: _selectedImage);
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'You have successfully saved a Zingibereaceae family')),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => sample2()),
                      );

                      // Implement logic to save data to the database
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: Color(0xFF023C0E),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ListView.builder(
                      shrinkWrap: true,
                      controller: ScrollController(),
                      itemCount: alldatalist
                          .length, // Ensure AllDataList is accessible here
                      itemBuilder: (context, index) {
                        return Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            height: 90,
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(alldatalist[index]['Name']),
                                // Text(AllDataList[index]['Text']),
                              ],
                            ));
                      }),
                ],
              ),
            ),
          ),
        ));
  }
}
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

void pickImageFromGallery() async {
  ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
  print('${file?.path}');

  if (file == null) return;
  String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

  //get reference to storage root
  // Reference referenceRoot = FirebaseStorage.instance.ref();
  // Reference referenceDirImages = referenceRoot.child('images');
  // Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

  //handle error
  // try {
  //   //store file
  //   await referenceImageToUpload.putFile(File(file!.path));
  //   //success get download url
  //   imageUrl = await referenceImageToUpload.getDownloadURL();
  // } catch (error) {}
}
