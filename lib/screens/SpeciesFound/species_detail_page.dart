import 'package:flutter/material.dart';

class SpeciesDetailPage extends StatelessWidget {
  final Map<String, Object?> species;

  const SpeciesDetailPage({super.key, required this.species});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(species['image_name']?.toString() ?? 'Species Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Species Name: ${species['image_name'] ?? 'Unknown'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Latitude: ${species['latitude'] ?? 'N/A'}'),
            Text('Longitude: ${species['longitude'] ?? 'N/A'}'),
            Text('Elevation: ${species['elevation'] ?? 'N/A'}'),
            Text('Capture Date: ${species['capture_date'] ?? 'N/A'}'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}