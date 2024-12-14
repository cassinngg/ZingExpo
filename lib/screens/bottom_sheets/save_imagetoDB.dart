// import 'dart:typed_data'; // Import Uint8List
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:zingexpo/database/database.dart';

// class SaveImageTodb extends StatefulWidget {
//   final int projectID;
//   final int quadratID;
//   final Uint8List image; // Change Blob to Uint8List
//   final String output; // Holds the identified species name
//   final String secondResult; // Holds additional details
//   final double? latitude; // Latitude
//   final double? longitude; // Longitude
//   final double? elevation; // Elevation
//   final VoidCallback onAdd; // Callback to refresh or update the UI

//   SaveImageTodb({
//     super.key,
//     required this.output,
//     required this.secondResult,
//     required this.latitude,
//     required this.longitude,
//     required this.elevation,
//     required this.onAdd,
//     required this.projectID,
//     required this.quadratID,
//     required this.image,
//   });

//   @override
//   _SaveImageTodbState createState() => _SaveImageTodbState();
// }

// class _SaveImageTodbState extends State<SaveImageTodb> {
//   final _formKey = GlobalKey<FormState>();
//   File? _selectedImage;
//   final TextEditingController quadratNameController = TextEditingController();
//   final TextEditingController lengthController = TextEditingController();
//   final TextEditingController widthController = TextEditingController();

//   // State variables for projects and quadrats
//   List<String> projects = [];
//   List<String> quadrats = [];
//   String? selectedProject;
//   String? selectedQuadrat;
//   String? projectName; // Variable to hold the project name

//   @override
//   void initState() {
//     super.initState();
//     _fetchProjectName(); // Fetch the project name
//     _fetchProjectsAndQuadrats();
//   }

//   Future<void> _fetchProjectName() async {
//     projectName = await LocalDatabase().getProjectNameByID(widget.projectID);
//     setState(() {}); // Update the UI
//   }

//   Future<void> _fetchProjectsAndQuadrats() async {
//     // Fetch projects and quadrats from the database
//     try {
//       projects = await LocalDatabase().fetchProjects();
//       quadrats = await LocalDatabase().fetchQuadrats();
//       setState(() {});
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching data: $e')),
//       );
//     }
//   }

//   Future<void> _pickImage() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     setState(() {
//       if (pickedFile != null) {
//         _selectedImage = File(pickedFile.path);
//       } else {
//         _selectedImage = null;
//       }
//     });
//   }

//   void _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       // Handle form submission
//       String quadratName = quadratNameController.text;
//       double? length = double.tryParse(lengthController.text);
//       double? width = double.tryParse(widthController.text);

//       // Save to database
//       try {
//         if (_selectedImage != null) {
//           // Convert the image file to bytes
//           final Uint8List bytes = await _selectedImage!.readAsBytes();

//           await LocalDatabase().insertImageData({
//             'image_name': widget.output.isNotEmpty
//                 ? widget.output.split(' - ').first
//                 : "Unidentified",
//             'additional_details': widget.secondResult,
//             'image_path': bytes, // Store Uint8List directly
//             'latitude': widget.latitude ?? 0.0,
//             'longitude': widget.longitude ?? 0.0,
//             'elevation': widget.elevation ?? 0.0,
//             "project_id": widget.projectID, // Add the project ID to the data
//             "quadrat_id": widget.quadratID,
//             "quadrat_name": quadratName,
//             "length": length,
//             "width": width,
//           });
//           widget.onAdd(); // Call the callback to refresh the UI
//           Navigator.pop(context); // Close the form
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error saving data: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Save Quadrat'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 GestureDetector(
//                   onTap: _pickImage,
//                   child: Container(
//                     width: double.infinity,
//                     height: 150,
//                     color: Colors.grey[300],
//                     child: _selectedImage != null
//                         ? Image.file(
//                             _selectedImage!,
//                             fit: BoxFit.cover,
//                           )
//                         : Image.memory(
//                             widget.image, // Use the Uint8List directly
//                             fit: BoxFit.cover,
//                           ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Column(
//                   children: [
//                     DropdownButtonFormField<String>(
//                       value: selectedProject,
//                       hint: Text(projectName.toString()),
//                       items: projects.map((project) {
//                         return DropdownMenuItem(
//                           value:
//                               project, // Assuming project has a unique identifier
//                           child: Text(project),
//                         );
//                       }).toList(),
//                       onChanged: _onProjectChanged,
//                       validator: (value) =>
//                           value == null ? 'Please select a project' : null,
//                     ),
//                     const SizedBox(height: 10),
//                     DropdownButtonFormField<String>(
//                       value: selectedQuadrat,
//                       hint: const Text('Select Quadrat'),
//                       items: quadrats.map((quadrat) {
//                         return DropdownMenuItem(
//                           value: quadrat,
//                           child: Text(quadrat),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           selectedQuadrat = value;
//                         });
//                       },
//                       validator: (value) =>
//                           value == null ? 'Please select a quadrat' : null,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   initialValue: widget.latitude.toString(),
//                   decoration: const InputDecoration(labelText: 'Latitude'),
//                   readOnly: true,
//                 ),
//                 TextFormField(
//                   initialValue: widget.longitude.toString(),
//                   decoration: const InputDecoration(labelText: 'Longitude'),
//                   readOnly: true,
//                 ),
//                 TextFormField(
//                   initialValue: widget.elevation.toString(),
//                   decoration: const InputDecoration(labelText: 'Elevation'),
//                   readOnly: true,
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   initialValue:
//                       widget.output.isNotEmpty ? widget.output : "Unidentified",
//                   decoration:
//                       const InputDecoration(labelText: 'Identified Species'),
//                   readOnly: true,
//                 ),
//                 TextFormField(
//                   initialValue: widget.secondResult.isNotEmpty
//                       ? widget.secondResult
//                       : "non-existent",
//                   decoration:
//                       const InputDecoration(labelText: 'Additional Details'),
//                   readOnly: true,
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _submitForm,
//                   child: const Text('Submit'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _onProjectChanged(String? value) async {
//     setState(() {
//       selectedProject = value;
//       selectedQuadrat = null; // Reset selected quadrat when project changes
//     });

//     if (selectedProject != null) {
//       // Fetch quadrats for the selected project
//       int projectId = int.parse(selectedProject!);
//       quadrats = await LocalDatabase().fetchQuadratsByProjectID(projectId);
//       setState(() {});
//     } else {
//       quadrats = []; // Reset quadrats if no project is selected
//     }
//   }
// }

import 'dart:ffi';
import 'dart:typed_data'; // Import Uint8List
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/screens/specific_project_Screens/specific_project_screen.dart';

class SaveImageTodb extends StatefulWidget {
  final int projectID;
  final int quadratID;
  final Uint8List image;
  final String output;
  final String secondResult;
  final double? latitude;
  final double? longitude;
  final double? elevation;
  final VoidCallback onAdd;

  SaveImageTodb({
    super.key,
    required this.output,
    required this.secondResult,
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.onAdd,
    required this.projectID,
    required this.quadratID,
    required this.image,
  });

  @override
  _SaveImageTodbState createState() => _SaveImageTodbState();
}

class _SaveImageTodbState extends State<SaveImageTodb> {
  final _formKey = GlobalKey<FormState>();
  File? image;
  final TextEditingController quadratNameController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();

  List<Map<String, dynamic>> projects = [];
  List<Map<String, dynamic>> quadrats = [];

  String? selectedProject;
  String? selectedQuadrat;

  @override
  void initState() {
    super.initState();
    selectedProject = widget.projectID.toString();
    _fetchProjectsAndQuadrats();
  }

  Future<void> _fetchProjectsAndQuadrats() async {
    try {
      projects = await LocalDatabase().fetchProjectsWithIds();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching projects: $e')),
      );
    }
  }

  Future<void> _fetchQuadratsByProject(String projectId) async {
    try {
      quadrats =
          await LocalDatabase().fetchQuadratsByProjectId(int.parse(projectId));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching quadrats: $e')),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Handle form submission
      String quadratName = quadratNameController.text;
      double? length = double.tryParse(lengthController.text);
      double? width = double.tryParse(widthController.text);

      // Check if the selected image is null
      // Since you want to use the image passed in the widget, you can skip this check
      // if (image == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('No image selected!')),
      //   );
      //   return; // Exit the function if no image is selected
      // }

      // Save to database
      try {
        // Use the image passed in the widget directly
        final Uint8List bytes = widget.image; // Use the Uint8List directly

        await LocalDatabase().insertImageData({
          'image_name': widget.output.isNotEmpty
              ? widget.output.split(' - ').first
              : "Unidentified",
          'additional_details': widget.secondResult,
          'image_path': bytes, // Store Uint8List directly
          'latitude': widget.latitude ?? 0.0,
          'longitude': widget.longitude ?? 0.0,
          'elevation': widget.elevation ?? 0.0,
          "project_id": widget.projectID,
          "quadrat_id": widget.quadratID,
          'capture_date': DateTime.now().toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Species saved successfully!')),
        );

        widget.onAdd(); // Call the callback to refresh UI
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving species: $e')),
        );
        print(e);
      }
    }
  }
  // void _submitForm() async {
  //   // if (_formKey.currentState!.validate()) {
  //   String quadratName = quadratNameController.text;
  //   // double? length = double.tryParse(lengthController.text);
  //   // double? width = double.tryParse(widthController.text);

  //   try {
  //     final Uint8List bytes = await _selectedImage!.readAsBytes();

  //     await LocalDatabase().insertImageData({
  //       'image_name': widget.output.isNotEmpty
  //           ? widget.output.split(' - ').first
  //           : "Unidentified",
  //       'additional_details': widget.secondResult,
  //       'image_path': widget.image,
  //       'latitude': widget.latitude,
  //       'longitude': widget.longitude,
  //       'elevation': widget.elevation,
  //       "project_id": selectedProject,
  //       "quadrat_id": selectedQuadrat,
  //       "quadrat_name": quadratName,
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Species saved successfully!')),
  //     );

  //     widget.onAdd();
  //     Navigator.pop(context);
  //     // } else {
  //     //   ScaffoldMessenger.of(context).showSnackBar(
  //     //     const SnackBar(
  //     //         content: Text(' Please pick an image before submitting.')),
  //     //   );
  //     // }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error saving data: $e')),
  //     );
  //   }
  //   // }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Image to Database'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 150,
                  color: Colors.grey[300],
                  child: Image.memory(
                    widget.image, // Use the Uint8List directly
                    fit: BoxFit.cover,
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: selectedProject,
                  decoration:
                      const InputDecoration(labelText: 'Select Project'),
                  items: projects.map((project) {
                    return DropdownMenuItem<String>(
                      value: project['project_id'].toString(),
                      child: Text(project['project_name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedProject = value;
                      if (value != null) {
                        _fetchQuadratsByProject(value);
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a project';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedQuadrat,
                  decoration:
                      const InputDecoration(labelText: 'Select Quadrat'),
                  items: quadrats.map((quadrat) {
                    return DropdownMenuItem<String>(
                      value: quadrat['quadrat_id'].toString(),
                      child: Text(quadrat['quadrat_name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedQuadrat = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a quadrat';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: widget.latitude.toString(),
                  decoration: const InputDecoration(labelText: 'Latitude'),
                  readOnly: true,
                ),
                TextFormField(
                  initialValue: widget.longitude.toString(),
                  decoration: const InputDecoration(labelText: 'Longitude'),
                  readOnly: true,
                ),
                TextFormField(
                  initialValue: widget.elevation.toString(),
                  decoration: const InputDecoration(labelText: 'Elevation'),
                  readOnly: true,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue:
                      widget.output.isNotEmpty ? widget.output : "Unidentified",
                  decoration:
                      const InputDecoration(labelText: 'Identified Species'),
                  readOnly: true,
                ),
                TextFormField(
                  initialValue: widget.secondResult.isNotEmpty
                      ? widget.secondResult
                      : "non-existent",
                  decoration:
                      const InputDecoration(labelText: 'Additional Details'),
                  readOnly: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// import 'dart:typed_data'; // Import Uint8List
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:zingexpo/database/database.dart';

// class SaveImageTodb extends StatefulWidget {
//   final int projectID;
//   final int quadratID;
//   final Uint8List image; // Change Blob to Uint8List
//   final String output; // Holds the identified species name
//   final String secondResult; // Holds additional details
//   final double? latitude; // Latitude
//   final double? longitude; // Longitude
//   final double? elevation; // Elevation
//   final VoidCallback onAdd; // Callback to refresh or update the UI

//   SaveImageTodb({
//     super.key,
//     required this.output,
//     required this.secondResult,
//     required this.latitude,
//     required this.longitude,
//     required this.elevation,
//     required this.onAdd,
//     required this.projectID,
//     required this.quadratID,
//     required this.image,
//   });

//   @override
//   _SaveImageTodbState createState() => _SaveImageTodbState();
// }

// class _SaveImageTodbState extends State<SaveImageTodb> {
//   final _formKey = GlobalKey<FormState>();
//   File? _selectedImage;
//   final TextEditingController quadratNameController = TextEditingController();
//   final TextEditingController lengthController = TextEditingController();
//   final TextEditingController widthController = TextEditingController();

//   // State variables for projects and quadrats
//   List<String> projects = [];
//   List<String> quadrats = [];
//   String? selectedProject;
//   String? selectedQuadrat;
//   String? projectid;
//   String? quadratid;

//   @override
//   void initState() {
//     super.initState();
//     _fetchProjectsAndQuadrats();
//   }

//   Future<void> _fetchProjectsAndQuadrats() async {
//     // Fetch projects and quadrats from the database
//     try {
//       projects = await LocalDatabase().fetchProjects();
//       quadrats = await LocalDatabase().fetchQuadrats();

//       // Set the initial values for the dropdowns based on projectID and quadratID
//       selectedProject = projects.firstWhere(
//         (project) => projectid == widget.projectID, // Assuming project has an id property
//         orElse: () => null.toString(),
//       );

//       selectedQuadrat = quadrats.firstWhere(
//         (quadrat) => quadratid == widget.quadratID, // Assuming quadrat has an id property
//         orElse: () => null.toString(),
//       );

//       setState(() {});
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching data: $e')),
//       );
//     }
//   }

//   Future<void> _pickImage() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     setState(() {
//       if (pickedFile != null) {
//         _selectedImage = File(pickedFile.path);
//       } else {
//         _selectedImage = null;
//       }
//     });
//   }

//   void _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       // Handle form submission
//       String quadratName = quadratNameController.text;
//       double? length = double.tryParse(lengthController.text);
//       double? width = double.tryParse(widthController.text);

//       // Save to database
//       try {
//         if (_selectedImage != null) {
//           // Convert the image file to bytes
//           final Uint8List bytes = await _selectedImage!.readAsBytes();

//           await LocalDatabase().insertImageData({
//             'image_name': widget.output.isNotEmpty
//                 ? widget.output.split(' - ').first
//                 : "Unidentified",
//             'additional_details': widget.secondResult,
//             'image_path': bytes, // Store Uint8List directly
//             'latitude': widget.latitude ?? 0.0,
//             'longitude': widget.longitude ?? 0.0,
//             'elevation': widget.elevation ?? 0.0,
//             "project_id": widget.projectID,
//             "quadrat_id": widget.quadratID,
//             'capture_date': DateTime.now().toIso8601String(),
//           });

//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Species saved successfully!')),
//           );

//           widget.onAdd(); // Call the callback to refresh UI
//           Navigator.of(context).pop(); // Close the form after saving
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Please select an image.')),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error saving species: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'Save Quadrat',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//               GestureDetector(
//                 onTap: _pickImage,
//                 child: Container(
//                   width: double.infinity,
//                   height: 150,
//                   color: Colors.grey[300],
//                   child: Image.memory(
//                     widget.image, // Use the Uint8List directly
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Column(
//                 children: [
//                   DropdownButtonFormField<String>(
//                     value: selectedProject,
//                     hint: const Text('Select Project'),
//                     items: projects.map((project) {
//                       return DropdownMenuItem(
//                         value: projectid.toString(), // Assuming Project has an id property
//                         child: Text(project.name), // Assuming Project has a name property
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedProject = value;
//                       });
//                     },
//                     validator: (value) =>
//                         value == null ? 'Please select a project' : null,
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   const Text(
//                     "X",
//                     style: TextStyle(fontSize: 15),
//                   ),
//                   const SizedBox(height: 10),
//                   DropdownButtonFormField<String>(
//                     value: selectedQuadrat,
//                     hint: const Text('Select Quadrat'),
//                     items: quadrats.map((quadrat) {
//                       return DropdownMenuItem(
//                         value: quadrat.id.toString(), // Assuming Quadrat has an id property
//                         child: Text(quadrat.name), // Assuming Quadrat has a name property
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedQuadrat = value;
//                       });
//                     },
//                     validator: (value) =>
//                         value == null ? 'Please select a quadrat' : null,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 initialValue: widget.latitude.toString(),
//                 decoration: const InputDecoration(labelText: 'Latitude'),
//                 readOnly: true,
//               ),
//               TextFormField(
//                 initialValue: widget.longitude.toString(),
//                 decoration: const InputDecoration(labelText: 'Longitude'),
//                 readOnly: true,
//               ),
//               TextFormField(
//                 initialValue: widget.elevation.toString(),
//                 decoration: const InputDecoration(labelText: 'Elevation'),
//                 readOnly: true,
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 initialValue:
//                     widget.output.isNotEmpty ? widget.output : "Unidentified",
//                 decoration:
//                     const InputDecoration(labelText: 'Identified Species'),
//                 readOnly: true,
//               ),
//               TextFormField(
//                 initialValue: widget.secondResult.isNotEmpty
//                     ? widget.secondResult
//                     : "non-existent",
//                 decoration:
//                     const InputDecoration(labelText: 'Additional Details'),
//                 readOnly: true,
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _submitForm,
//                 child: const Text('Submit'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }