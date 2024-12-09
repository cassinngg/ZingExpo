import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/screens/meta_data_related/image_meta_data.dart';
import 'package:zingexpo/sample/add%20button.dart';
import 'package:zingexpo/screens/homepage_screens/home.dart';
import 'package:zingexpo/widgets/boxes/input_box.dart';
import 'package:zingexpo/widgets/buttons/submit_button.dart';
import 'package:zingexpo/widgets/buttons/submit_button_icon.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:zingexpo/database/firestore_service.dart';

class AddProject extends StatefulWidget {
  final Function onAdd;

  const AddProject({required this.onAdd, super.key});

  @override
  State<AddProject> createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  File? _selectedImage;
  String imageUrl = '';
  List<Map<String, dynamic>> allData = [];

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
      allData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Project',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: Color(0xFF097500),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 10, left: 5, right: 5, bottom: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10, left: 5, right: 5, bottom: 5),
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromARGB(210, 2, 60, 14),
                    ),
                    child: Center(
                      child: _selectedImage != null
                          ? Image.file(_selectedImage!, fit: BoxFit.fill)
                          : const PhosphorIcon(PhosphorIconsFill.imageSquare,
                              size: 100),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0, left: 5, right: 5),
                  child: SubmitButtonWithAddIcon(
                    label: 'Capture Image',
                    onPressed: _selectOrCaptureImage,
                  ),
                ),
                const IconButton(
                  onPressed: pickImageFromGallery,
                  icon: Icon(
                    Icons.photo,
                    color: Colors.green,
                    size: 30,
                  ),
                ),
                InputBox(
                    hint: 'Project Name', controller: project_nameController),
                InputBox(
                  hint: 'Description',
                  controller: descriptionController,
                ),
                InputBox(
                  hint: 'Project Location',
                  controller: locationController,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
        child: SubmitButton(
          label: 'Add Project',
          onPressed: () async {
            // final String title = titleController.text;
            // final String species = speciesController.text;
            // final String quadrat = quadratController.text;

            if (project_nameController.text.isNotEmpty) {
              await LocalDatabase().addProject(
                  projectName: project_nameController.text,
                  projectDescription: descriptionController.text,
                  projectLocation: locationController.text,
                  imageFile: _selectedImage);
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('You have successfully saved a Project.')),
            );
            widget.onAdd();
            // await _loadData();
            // setState(() {});
            Navigator.pop(context);

            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => Home()),
            // );
          },
        ),
      ),
    );
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
}
