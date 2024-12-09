import 'package:flutter/material.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/screens/SpeciesFound/species_detail_page.dart'; // Required for LocalDatabase

class SpeciesFoundInfo extends StatefulWidget {
  final int projectID;

  SpeciesFoundInfo({required this.projectID});

  @override
  _SpeciesFoundInfoState createState() => _SpeciesFoundInfoState();
}

class _SpeciesFoundInfoState extends State<SpeciesFoundInfo> {
  List<Map<String, Object?>> identifiedSpecies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchIdentifiedSpecies();
  }

  Future<void> fetchIdentifiedSpecies() async {
    try {
      identifiedSpecies =
          await LocalDatabase().getIdentifiedSpeciesByQuadrat(widget.projectID);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching identified species: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Species Found Info'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : identifiedSpecies.isEmpty
              ? const Center(child: Text('No identified species found.'))
              : ListView(
                  children: _buildSpeciesList(),
                ),
    );
  }

  List<Widget> _buildSpeciesList() {
    // Group species by their quadrat_id (or any other grouping criteria)
    Map<String, List<Map<String, Object?>>> groupedSpecies = {};
    for (var species in identifiedSpecies) {
      String quadratId =
          species['quadrat_id']?.toString() ?? 'Unknown'; // Group by quadrat_id
      if (!groupedSpecies.containsKey(quadratId)) {
        groupedSpecies[quadratId] = [];
      }
      groupedSpecies[quadratId]!.add(species);
    }

    // Create a list of ExpansionTiles for each quadrat
    return groupedSpecies.entries.map((entry) {
      String quadratId = entry.key;
      List<Map<String, Object?>> speciesList = entry.value;

      return ExpansionTile(
        title: Text('Quadrat ID: $quadratId'),
        children: speciesList.map((species) {
          String? imageName = species['image_name'] as String?;
          return ListTile(
            title: Text(imageName ?? 'Unknown Species'),
            subtitle: Text(
              'Latitude: ${species['latitude'] ?? 'N/A'}, '
              'Longitude: ${species['longitude'] ?? 'N/A'}, '
              'Elevation: ${species['elevation'] ?? 'N/A'}, '
              'Capture Date: ${species['capture_date'] ?? 'N/A'}',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SpeciesDetailPage(species: species),
                ),
              );
            },
          );
        }).toList(),
      );
    }).toList();
  }
}
