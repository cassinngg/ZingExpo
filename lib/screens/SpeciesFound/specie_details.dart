import 'package:flutter/material.dart';
import 'package:zingexpo/database/database.dart';

class SpeciesDetails extends StatefulWidget {
  final String speciesinfo;
  const SpeciesDetails({super.key, required this.speciesinfo});

  @override
  State<SpeciesDetails> createState() => _SpeciesDetailsState();
}

class _SpeciesDetailsState extends State<SpeciesDetails> {
  @override
  void initState() {
    super.initState();
    _loaddata();
  }

  String identifiedSpecie = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> gingerData = [];
  Map<String, dynamic>? selectedGinger;

  Future<void> _loaddata() async {
    final data = await LocalDatabase().fetchGingers();
    setState(() {
      gingerData = data;
      _isLoading = false;
    });
  }

  Future<void> _loadData() async {
    final data = await LocalDatabase().fetchGingers();
    setState(() {
      gingerData = data;
      selectedGinger = gingerData.firstWhere(
        (ginger) => ginger['ginger_name'] == widget.speciesinfo,
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.speciesinfo),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : selectedGinger != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(selectedGinger!['ginger_image']),
                      const SizedBox(height: 16),
                      Text(
                        cleanImageName(selectedGinger!['ginger_name']),
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedGinger!['ginger_description'],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                )
              : const Center(child: Text('No data found for this species.')),
    );
  }

  String cleanImageName(String imageName) {
    // Remove all digits from the string
    String withoutNumbers = imageName.replaceAll(RegExp(r'\d+'), '');

    // Optionally, you can split the string by spaces or underscores and join it back
    List<String> parts =
        withoutNumbers.split(RegExp(r'[_\s]+')); // Split by underscore or space
    return parts.join(' '); // Join back with a space
  }
}
