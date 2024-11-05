import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zingexpo/database/database.dart';
import 'package:flutter/material.dart';

class SpeciesDisplay extends StatefulWidget {
  @override
  _SpeciesDisplayState createState() => _SpeciesDisplayState();
}

class _SpeciesDisplayState extends State<SpeciesDisplay> {
  List<Map<String, dynamic>> _speciesList = [];

  Future<void> _loadSpecies() async {
    final db = await LocalDatabase().database;
    final species = await db.query('Species');
    setState(() {
      _speciesList = species;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSpecies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Species List')),
      body: ListView.builder(
        itemCount: _speciesList.length,
        itemBuilder: (context, index) {
          final species = _speciesList[index];
          return ListTile(
            title: Text(species['species_name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description: ${species['species_description']}'),
                Text('Sub-family: ${species['sub_family']}'),
                Text('Tribe: ${species['tribe']}'),
                Text('Genera ID: ${species['genera_id']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class addSpeciesLibrary extends StatefulWidget {
  @override
  State<addSpeciesLibrary> createState() => _addSpeciesLibraryState();
}

class _addSpeciesLibraryState extends State<addSpeciesLibrary> {
  File? _selectedImage;
  String imageUrl = '';
  List<Map<String, dynamic>> _allData = [];

  final TextEditingController species_nameController = TextEditingController();
  final TextEditingController species_descriptionController =
      TextEditingController();
  final TextEditingController sub_familyController = TextEditingController();
  final TextEditingController tribe_Controller = TextEditingController();

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
          title: Text('Add Species'),
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
                    controller: species_nameController,
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
                    controller: species_descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Species Description',
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
                    controller: sub_familyController,
                    decoration: InputDecoration(
                      labelText: 'Sub-family',
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
                    controller: tribe_Controller,
                    decoration: InputDecoration(
                      labelText: 'Tribe',
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

                      if (species_nameController.text.isNotEmpty) {
                        await LocalDatabase().addSpecies(
                            species_name: species_nameController.text,
                            species_description:
                                species_descriptionController.text,
                            sub_family: sub_familyController.text,
                            tribe: tribe_Controller.text,
                            imageFile: _selectedImage);
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('You have successfully saved a Species')),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SpeciesDisplay()),
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
                            margin: const EdgeInsets.symmetric(horizontal: 20),
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
