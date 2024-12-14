// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:zingexpo/database/database.dart';
// import 'package:zingexpo/widgets/circle_info.dart';

// class CircularPlant extends StatefulWidget {
//   final String title;
//   final String imageUrl;
//   final String plantId;

//   const CircularPlant({super.key,
//     required this.title,
//     required this.imageUrl,
//     required this.plantId,
//   });

//   @override
//   State<CircularPlant> createState() => _CircularPlantState();
// }

// class _CircularPlantState extends State<CircularPlant> {
//   // Map<String, dynamic>? currentPlantDetails;
//   List<Map<String, dynamic>> allData = [];
//   // bool _isLoading = true;
//   // Uncomment the next line if you actually need to use DatabaseService
//   // final DatabaseService _databaseService = DatabaseService.instance;

//   Future<void> _loadData() async {
//     try {
//       final data = await LocalDatabase().readData();
//       setState(() {
//         allData = data;
//         // _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         // _isLoading = false;
//       });
//       // Handle error (show dialog, log, etc.)
//     }
//   }

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   _initDatabase();
//   // }
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: InkWell(
//         onTap: () {
//           // Check if plantId is not empty
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => CircleInfoPage(plantId: widget.plantId)),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               CircleAvatar(
//                 radius: 48, // Adjust the radius as needed
//                 backgroundImage: AssetImage(widget.imageUrl),
//               ),
//               Text(
//                 widget.title,
//                 style: GoogleFonts.poppins(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart'; // Required for path manipulation
import 'dart:typed_data'; // Required for Uint8List

import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/screens/SpeciesFound/species_found_info.dart'; // Required for SpeciesFoundInfo

class CircleInfoPage extends StatefulWidget {
  final int projectId;
  final Map<String, dynamic> allData;

  CircleInfoPage({required this.projectId, required this.allData});

  @override
  _CircleInfoPageState createState() => _CircleInfoPageState();
}

class _CircleInfoPageState extends State<CircleInfoPage> {
  List<Map<String, Object?>> identifiedSpecies = [];
  bool isLoading = true; // Loading state
  List<Map<String, dynamic>> groupedImages = [];

  @override
  void initState() {
    super.initState();
    fetchIdentifiedSpecies(widget.projectId);
    fetchGroupedImages(); // Fetch grouped images
  }

  Future<void> fetchGroupedImages() async {
    try {
      groupedImages =
          await LocalDatabase().getImagesByProject(widget.projectId);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching grouped images: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchIdentifiedSpecies(int projectId) async {
    try {
      final projectID =
          widget.allData['project_id']; // Get the selected project ID
      if (projectID != null) {
        // Fetch identified species from the local database based on projectId
        identifiedSpecies =
            await LocalDatabase().getIdentifiedSpeciesByQuadrat(projectId);
        setState(() {
          isLoading = false; // Set loading to false after fetching data
        });
      }
    } catch (e) {
      print('Error fetching identified species: $e');
      setState(() {
        isLoading = false; // Set loading to false in case of error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : identifiedSpecies.isEmpty
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'No identified images yet.',
                            style: TextStyle(fontSize: 10),
                          ),
                          Text(
                            'Start Identifying Images below',
                            style: TextStyle(fontSize: 7),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    children: groupedImages.map((group) {
                      Uint8List? imageBytes = group['image_path'] as Uint8List?;
                      String? imageName = group['image_name'] as String?;
                      int totalCount = group['total_count'] as int? ?? 0;

                      return GestureDetector(
                        onTap: () {
                          // Filter species based on the image name of the clicked group
                          List<Map<String, Object?>> speciesInGroup =
                              identifiedSpecies.where((species) {
                            return species['image_name'] == imageName;
                          }).toList();

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SpeciesFoundInfo(
                                projectID: widget.projectId,
                                species:
                                    speciesInGroup, // Pass the filtered species
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.50,
                                  height:
                                      MediaQuery.of(context).size.height * 0.10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: imageBytes != null
                                          ? MemoryImage(
                                              imageBytes) // Use MemoryImage for Uint8List
                                          : const AssetImage(
                                                  'assets/placeholder.jpg')
                                              as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 24,
                                  child: Container(
                                    width: 24.0,
                                    height: 24.0,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.fromARGB(255, 8, 82, 10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        totalCount
                                            .toString(), // Display the count
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              cleanImageName(imageName
                                  .toString()), // Clean the image name before displaying
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontStyle: FontStyle.italic,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.02,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
    );
  }

  String cleanImageName(String imageName) {
    // Remove all digits from the string
    String withoutNumbers = imageName.replaceAll(RegExp(r'\d+'), '');

    // Optionally, you can split the string by spaces or underscores and join it back
    List<String> parts = withoutNumbers.split(RegExp(r'[_\s]+'));
    return parts.join(' '); // Join back with a space
  }
}
