import 'package:flutter/material.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/screens/homepage_screens/home.dart';
import 'package:zingexpo/screens/specific_project_Screens/specific_project_screen.dart';

class EditQuadrat extends StatefulWidget {
  final Map<String, dynamic> allData;
  final int projectID;
  final int quadratID;
  final Function(Map<String, dynamic>) onUpdate;

  EditQuadrat({
    Key? key,
    required this.allData,
    required this.projectID,
    required this.onUpdate,
    required this.quadratID,
  }) : super(key: key);

  @override
  _EditQuadratState createState() => _EditQuadratState();
}

class _EditQuadratState extends State<EditQuadrat> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quadratnameController;
  late TextEditingController _lengthController;
  late TextEditingController _widthController;

  @override
  void initState() {
    super.initState();
    _quadratnameController =
        TextEditingController(text: widget.allData['quadrat_name']);
    _lengthController = TextEditingController(text: widget.allData['length']);
    _widthController = TextEditingController(text: widget.allData['width']);
  }

  @override
  void dispose() {
    _quadratnameController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
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
                  Map<String, dynamic> updatedQuadratData = {
                    'quadrat_id': widget.projectID,
                    'quadrat_name': _quadratnameController.text,
                    'length': _lengthController.text,
                    'width': _widthController.text,
                  };

                  try {
                    await LocalDatabase().updateQuadrat(
                      quadratID: widget.projectID,
                      quadratName: _quadratnameController.text,
                      length: _lengthController.text,
                      width: _widthController.text,
                    );
                    widget.onUpdate(updatedQuadratData);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SpecificProjectsPage(
                              allData: widget.allData,
                              projectID: widget.projectID,
                              onDelete: () {},
                              onProjectUpdated: () {})),
                    );

                    // widget.onUpdate(updatedQuadratData);
                    // Navigator.pop(context);
                    // SpecificProjectsPage(
                    //     allData: widget.allData,
                    //     projectID: widget.projectID,
                    //     onDelete: () {},
                    //     onProjectUpdated: () {});
                  }
                  //   Navigator.of(context).pushAndRemoveUntil(
                  //     MaterialPageRoute(
                  //         builder: (context) => SpecificProjectsPage(
                  //             allData: widget.allData,
                  //             projectID: widget.projectID,
                  //             onDelete: () {},
                  //             onProjectUpdated: () {})),
                  //     (route) => false,
                  //   );
                  // }

                  // Navigator.pop(context);
                  catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating quadrat: $e')),
                    );
                  }
                }
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
                controller: _quadratnameController,
                decoration: const InputDecoration(labelText: 'Project Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lengthController,
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
                controller: _widthController,
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
