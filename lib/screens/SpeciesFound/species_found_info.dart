import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:zingexpo/screens/SpeciesFound/species_detail_page.dart'; // Required for SpeciesDetailPage
import 'package:zingexpo/database/database.dart'; // Required for database operations

class SpeciesFoundInfo extends StatefulWidget {
  final int projectID;
  final List<Map<String, Object?>> species; // New parameter for species

  SpeciesFoundInfo({required this.projectID, required this.species});

  @override
  _SpeciesFoundInfoState createState() => _SpeciesFoundInfoState();
}

class _SpeciesFoundInfoState extends State<SpeciesFoundInfo> {
  String? projectName;
  String? quadratName;

  @override
  void initState() {
    super.initState();
    fetchProjectAndQuadratNames();
  }

  Future<void> fetchProjectAndQuadratNames() async {
    try {
      projectName = await LocalDatabase().getProjectNameById(widget.projectID);
      // Assuming you have a way to get the quadrat ID from the species data
      // Here I'm just using the first species item to get the quadrat ID
      int? quadratId = widget.species.isNotEmpty
          ? widget.species[0]['quadrat_id'] as int?
          : null;
      if (quadratId != null) {
        quadratName = await LocalDatabase().getQuadratNameByID(quadratId);
      }
      setState(() {}); // Update the UI after fetching names
    } catch (e) {
      print('Error fetching project or quadrat names: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Species Found Info'),
      ),
      body: widget.species.isEmpty
          ? const Center(child: Text('No identified species found.'))
          : ListView(
              padding: const EdgeInsets.all(8.0),
              children: _buildSpeciesList(),
            ),
    );
  }

  List<Widget> _buildSpeciesList() {
    // Create a list of Card widgets for each species
    return widget.species.map((species) {
      String? imageName = species['image_name'] as String?;
      Uint8List? imageBytes = species['image_path']
          as Uint8List?; // Assuming this is how the image is stored

      return Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageBytes != null)
                Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                  height: 150,
                  width: double.infinity,
                ),
              const SizedBox(height: 8),
              Text(
                imageName ?? 'Unknown Species',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Project: ${projectName ?? 'Loading...'}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Quadrat: ${quadratName ?? 'Loading...'}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Latitude: ${species['latitude'] ?? 'N/A'}, '
                'Longitude: ${species['longitude'] ?? 'N/A'}, '
                'Elevation: ${species['elevation'] ?? 'N/A'}, '
                'Capture Date: ${species['capture_date'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpeciesDetailPage(species: species),
                    ),
                  );
                },
                child: const Text('View Details'),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
