// import 'package:flutter/material.dart';
// import 'package:zingexpo/database/database.dart';

// class EditProject extends StatefulWidget {
//   Map<String, dynamic> allData;
//   final int projectID;
//   final Function(String) onUpdate; // Add this line
//   final Function(Map<String, dynamic>) onProjectUpdated;

//   EditProject(
//       {Key? key,
//       required this.allData,
//       required this.projectID,
//       required this.onUpdate,
//       required this.onProjectUpdated})
//       : super(key: key);

//   @override
//   _EditProjectState createState() => _EditProjectState();
// }

// class _EditProjectState extends State<EditProject> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _nameController;
//   late TextEditingController _descriptionController;
//   late TextEditingController _locationController;
//   List<Map<String, dynamic>> allData = [];

//   @override
//   void initState() {
//     super.initState();
//     _nameController =
//         TextEditingController(text: widget.allData['project_name']);
//     _descriptionController =
//         TextEditingController(text: widget.allData['project_description']);
//     _locationController =
//         TextEditingController(text: widget.allData['project_location']);
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     _locationController.dispose();
//     super.dispose();
//   }

//   void _saveChanges() async {
//     if (_formKey.currentState!.validate()) {
//       await LocalDatabase().updateProject(
//         projectID: widget.projectID,
//         projectName: _nameController.text,
//         projectDescription: _descriptionController.text,
//         projectLocation: _locationController.text,
//         // Pass the image file if you want to update the image
//         // imageFile: selectedImageFile, // Uncomment if you have a file to update
//       );
//       // widget.onUpdate(_nameController.text); // Call the onUpdate callback
//       // widget._onProjectUpdated(updatedData);
//       Navigator.pop(context);
//     }
//   }

//   void _onProjectUpdated(Map<String, dynamic> updatedData) {
//     setState(() {
//       widget.allData = updatedData;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Project'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(labelText: 'Project Name'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a project name';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration:
//                     const InputDecoration(labelText: 'Project Description'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a project description';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _locationController,
//                 decoration:
//                     const InputDecoration(labelText: 'Project Location'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a project location';
//                   }
//                   return null;
//                 },
//               ),
//               // Add an image picker if needed
//               ElevatedButton(
//                 onPressed: _saveChanges,
//                 child: const Text('Save Changes'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/screens/homepage_screens/home.dart';

class EditProject extends StatefulWidget {
  final Map<String, dynamic> allData;
  final int projectID;
  final Function(Map<String, dynamic>) onUpdate; 

  EditProject({
    Key? key,
    required this.allData,
    required this.projectID,
    required this.onUpdate,
  }) : super(key: key);
 
  @override
  _EditProjectState createState() => _EditProjectState();
}

class _EditProjectState extends State<EditProject> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.allData['project_name']);
    _descriptionController =
        TextEditingController(text: widget.allData['project_description']);
    _locationController =
        TextEditingController(text: widget.allData['project_location']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Quadrat'),
          content: const Text('This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Create updated data map
                  Map<String, dynamic> updatedData = {
                    'project_id': widget.projectID,
                    'project_name': _nameController.text,
                    'project_description': _descriptionController.text,
                    'project_location': _locationController.text,
                  };

                  await LocalDatabase().updateProject(
                    projectID: widget.projectID,
                    projectName: _nameController.text,
                    projectDescription: _descriptionController.text,
                    projectLocation: _locationController.text,
                    // imageFile: selectedImageFile, 
                  );

                  widget.onUpdate(updatedData);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );
                  // Navigator.pop(context);
                }
                // Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Project Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Project Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration:
                    const InputDecoration(labelText: 'Project Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project location';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
