import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/location/location.dart';
import 'package:zingexpo/sample/bottomnavbarsample.dart';
import 'package:zingexpo/sample/sample2.dart';
import 'package:zingexpo/samples/add%20button.dart';
import 'package:zingexpo/samples/try.dart';
import 'package:zingexpo/screens/home.dart';
import 'package:zingexpo/screens/project_page.dart';
import 'package:zingexpo/widgets/boxes/input_box.dart';
import 'package:zingexpo/widgets/buttons/submit_button.dart';
import 'package:zingexpo/widgets/buttons/submit_button_icon.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:zingexpo/database/firestore_service.dart';

class AddQuadrat extends StatefulWidget {
  final Map<String, dynamic> allData;
  final int projectID;
  final Function onAdd;

  const AddQuadrat({
    super.key,
    required this.allData,
    required this.projectID,
    required this.onAdd,
  });

  @override
  State<AddQuadrat> createState() => _AddQuadratState();
}

class _AddQuadratState extends State<AddQuadrat> {
  File? _selectedImage;
  String imageUrl = '';
  List<Map<String, dynamic>> allData = [];
  String _locationMessage = "Getting location...";

  final TextEditingController quadrat_nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

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

  Future<void> _getLocation() async {
    LocationService locationService = LocationService();
    try {
      LocationData locationData = await locationService.getCurrentLocation();
      setState(() {
        _locationMessage =
            "Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude}";
      });
    } catch (e) {
      setState(() {
        _locationMessage = e.toString();
      });
    }
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
        title: Text(
          'Add Quadrat',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color(0xFF097500),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15),
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
                IconButton(
                  onPressed: pickImageFromGallery,
                  icon: const Icon(
                    Icons.photo,
                    color: Colors.green,
                    size: 30,
                  ),
                ),
                InputBox(
                  controller: quadrat_nameController,
                  hint: 'Quadrat Name',
                ),
                InputBox(
                  hint: 'Species',
                  controller: descriptionController,
                ),

                // ListView.builder(
                //     shrinkWrap: true,
                //     controller: ScrollController(),
                //     itemCount: alldatalist
                //         .length, // Ensure AllDataList is accessible here
                //     itemBuilder: (context, index) {
                //       return Container(
                //           margin: EdgeInsets.symmetric(horizontal: 20),
                //           height: 90,
                //           width: double.infinity,
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: [
                //               Text(alldatalist[index]['Name']),
                //               // Text(AllDataList[index]['Text']),
                //             ],
                //           ));
                //     }),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
        child: SubmitButton(
          label: 'Add Quadrat',
          onPressed: () async {
            if (quadrat_nameController.text.isNotEmpty) {
              await LocalDatabase().addQuadrats(
                  quadrat_name: quadrat_nameController.text,
                  quadrat_description: descriptionController.text,
                  imageFile: _selectedImage,
                  projectID: widget.projectID);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Quadrat saved')));
            }
            widget.onAdd();

            Navigator.pop(context); // Go back
            // Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => FloatingSample(
            //             allData: widget.allData, projectID: widget.projectID)));
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
