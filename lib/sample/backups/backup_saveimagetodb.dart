import 'dart:ffi';
import 'dart:typed_data'; // Import Uint8List
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zingexpo/database/database.dart';

class BackupSaveImageTodb extends StatefulWidget {
  final int projectID;
  final int quadratID;
  final Uint8List image;
  final String output;
  final String secondResult;
  final double? latitude;
  final double? longitude;
  final double? elevation;
  final VoidCallback onAdd;

  BackupSaveImageTodb({
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
  _BackupSaveImageTodbState createState() => _BackupSaveImageTodbState();
}

class _BackupSaveImageTodbState extends State<BackupSaveImageTodb> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
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

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      } else {
        _selectedImage = null;
      }
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String quadratName = quadratNameController.text;
      double? length = double.tryParse(lengthController.text);
      double? width = double.tryParse(widthController.text);

      try {
        if (_selectedImage != null) {
          final Uint8List bytes = await _selectedImage!.readAsBytes();

          await LocalDatabase().insertImageData({
            'image_name': widget.output.isNotEmpty
                ? widget.output.split(' - ').first
                : "Unidentified",
            'additional_details': widget.secondResult,
            'image_path': bytes,
            'latitude': widget.latitude ?? 0.0,
            'longitude': widget.longitude ?? 0.0,
            'elevation': widget.elevation ?? 0.0,
            "project_id": int.parse(selectedProject!),
            "quadrat_id": int.parse(selectedQuadrat!),
            "quadrat_name": quadratName,
            "length": length,
            "width": width,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Species saved successfully!')),
          );

          widget.onAdd();
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(' Please pick an image before submitting.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Image to Database'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedProject,
                decoration: const InputDecoration(labelText: 'Select Project'),
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
                decoration: const InputDecoration(labelText: 'Select Quadrat'),
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
                controller: lengthController,
                decoration: const InputDecoration(labelText: 'Length'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a length';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: widthController,
                decoration: const InputDecoration(labelText: 'Width'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a width';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
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
    );
  }
}


// import 'dart:ffi';
// import 'dart:typed_data'; // Import Uint8List
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:zingexpo/database/database.dart';
// import 'package:zingexpo/screens/specific_project_Screens/specific_project_screen.dart';

// class SaveImageTodb extends StatefulWidget {
//   final int projectID;
//   final int quadratID;
//   final Uint8List image;
//   final String output;
//   final String secondResult;
//   final double? latitude;
//   final double? longitude;
//   final double? elevation;
//   final VoidCallback onAdd;

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
//   File? image;
//   final TextEditingController quadratNameController = TextEditingController();
//   final TextEditingController lengthController = TextEditingController();
//   final TextEditingController widthController = TextEditingController();

//   List<Map<String, dynamic>> projects = [];
//   List<Map<String, dynamic>> quadrats = [];

//   String? selectedProject;
//   String? selectedQuadrat;

//   @override
//   void initState() {
//     super.initState();
//     selectedProject = widget.projectID.toString();
//     _fetchProjectsAndQuadrats();
//   }

//   Future<void> _fetchProjectsAndQuadrats() async {
//     try {
//       projects = await LocalDatabase().fetchProjectsWithIds();
//       setState(() {});
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching projects: $e')),
//       );
//     }
//   }

//   Future<void> _fetchQuadratsByProject(String projectId) async {
//     try {
//       quadrats =
//           await LocalDatabase().fetchQuadratsByProjectId(int.parse(projectId));
//       setState(() {});
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching quadrats: $e')),
//       );
//     }
//   }

//   void _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       // Handle form submission
//       String quadratName = quadratNameController.text;
//       double? length = double.tryParse(lengthController.text);
//       double? width = double.tryParse(widthController.text);

//       // Check if the selected image is null
//       // Since you want to use the image passed in the widget, you can skip this check
//       // if (image == null) {
//       //   ScaffoldMessenger.of(context).showSnackBar(
//       //     const SnackBar(content: Text('No image selected!')),
//       //   );
//       //   return; // Exit the function if no image is selected
//       // }

//       // Save to database
//       try {
//         // Use the image passed in the widget directly
//         final Uint8List bytes = widget.image; // Use the Uint8List directly

//         await LocalDatabase().insertImageData({
//           'image_name': widget.output.isNotEmpty
//               ? widget.output.split(' - ').first
//               : "Unidentified",
//           'additional_details': widget.secondResult,
//           'image_path': bytes, // Store Uint8List directly
//           'latitude': widget.latitude ?? 0.0,
//           'longitude': widget.longitude ?? 0.0,
//           'elevation': widget.elevation ?? 0.0,
//           "project_id": widget.projectID,
//           "quadrat_id": widget.quadratID,
//           'capture_date': DateTime.now().toIso8601String(),
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Species saved successfully!')),
//         );

//         widget.onAdd(); // Call the callback to refresh UI
//         Navigator.pop(context);
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error saving species: $e')),
//         );
//         print(e);
//       }
//     }
//   }
//   // void _submitForm() async {
//   //   // if (_formKey.currentState!.validate()) {
//   //   String quadratName = quadratNameController.text;
//   //   // double? length = double.tryParse(lengthController.text);
//   //   // double? width = double.tryParse(widthController.text);

//   //   try {
//   //     final Uint8List bytes = await _selectedImage!.readAsBytes();

//   //     await LocalDatabase().insertImageData({
//   //       'image_name': widget.output.isNotEmpty
//   //           ? widget.output.split(' - ').first
//   //           : "Unidentified",
//   //       'additional_details': widget.secondResult,
//   //       'image_path': widget.image,
//   //       'latitude': widget.latitude,
//   //       'longitude': widget.longitude,
//   //       'elevation': widget.elevation,
//   //       "project_id": selectedProject,
//   //       "quadrat_id": selectedQuadrat,
//   //       "quadrat_name": quadratName,
//   //     });

//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(content: Text('Species saved successfully!')),
//   //     );

//   //     widget.onAdd();
//   //     Navigator.pop(context);
//   //     // } else {
//   //     //   ScaffoldMessenger.of(context).showSnackBar(
//   //     //     const SnackBar(
//   //     //         content: Text(' Please pick an image before submitting.')),
//   //     //   );
//   //     // }
//   //   } catch (e) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Error saving data: $e')),
//   //     );
//   //   }
//   //   // }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Save Image to Database'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 Container(
//                   width: double.infinity,
//                   height: 150,
//                   color: Colors.grey[300],
//                   child: Image.memory(
//                     widget.image, // Use the Uint8List directly
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 DropdownButtonFormField<String>(
//                   value: selectedProject,
//                   decoration:
//                       const InputDecoration(labelText: 'Select Project'),
//                   items: projects.map((project) {
//                     return DropdownMenuItem<String>(
//                       value: project['project_id'].toString(),
//                       child: Text(project['project_name']),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedProject = value;
//                       if (value != null) {
//                         _fetchQuadratsByProject(value);
//                       }
//                     });
//                   },
//                   validator: (value) {
//                     if (value == null) {
//                       return 'Please select a project';
//                     }
//                     return null;
//                   },
//                 ),
//                 DropdownButtonFormField<String>(
//                   value: selectedProject,
//                   decoration:
//                       const InputDecoration(labelText: 'Select Project'),
//                   items: quadrats.map((quadrat) {
//                     return DropdownMenuItem<String>(
//                       value: quadrat['quadrat_id'].toString(),
//                       child: Text(quadrat['quadrat_name']),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedProject = value;
//                       if (value != null) {
//                         _fetchQuadratsByProject(value);
//                       }
//                     });
//                   },
//                   validator: (value) {
//                     if (value == null) {
//                       return 'Please select a project';
//                     }
//                     return null;
//                   },
//                 ),
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
// }

