import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zingexpo/database/database.dart';

class AddQuadratForm extends StatefulWidget {
  final int projectID;
  final VoidCallback onAdd;

  AddQuadratForm({required this.projectID, required this.onAdd});

  @override
  _AddQuadratFormState createState() => _AddQuadratFormState();
}

class _AddQuadratFormState extends State<AddQuadratForm> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  String? quadratName;
  double? length;
  double? width;

  final TextEditingController quadratNameController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
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
      quadratName = quadratNameController.text;
      length = double.tryParse(lengthController.text);
      width = double.tryParse(widthController.text);

      await LocalDatabase().addQuadrats(
        quadratName: quadratName!,
        quadratDescription: descriptionController.text,
        length: lengthController.text,
        width: widthController.text,
        imageFile: _selectedImage,
        projectID: widget.projectID,
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Quadrat saved'),
        backgroundColor: Color.fromARGB(255, 136, 2, 47),
      ));

      widget.onAdd();
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    try {
      await LocalDatabase().database;
      print('Database initialized successfully');
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Name This Quadrat',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 150,
                color: Colors.grey[300],
                child: _selectedImage == null
                    ? Center(child: Text('Tap to add image'))
                    : Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: quadratNameController,
              decoration: InputDecoration(labelText: 'Quadrat Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a quadrat name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: lengthController,
              decoration: InputDecoration(labelText: 'Length'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter length';
                }
                return null;
              },
            ),
            TextFormField(
              controller: widthController,
              decoration: InputDecoration(labelText: 'Width'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter width';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
