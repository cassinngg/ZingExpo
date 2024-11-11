import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/sample/sam.dart';
import 'package:zingexpo/screens/meta_data_related/image_meta_data.dart';
import 'package:zingexpo/widgets/specific_quadrat_page.dart';

class QuadratCard extends StatelessWidget {
  final Map<String, dynamic> allData;
  final int quadratID;
  final int projectID;
  final VoidCallback onDelete; // Callback for deletion

  const QuadratCard({
    super.key,
    required this.allData,
    required this.quadratID,
    required this.onDelete,
    required this.projectID,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Container(); // Or show a placeholder widget
        }

        // final size = MediaQuery.of(context).size;

        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 244,
            height: 288,
            color: const Color(0xFFF0F0F0),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: allData['quadrat_image'] != null
                                ? Image.memory(allData['quadrat_image'],
                                    width: 180,
                                    height: 124.17,
                                    fit: BoxFit.cover)
                                : Image.asset(
                                    "assets/zingiber_zerumbet.jpg",
                                    width: 180,
                                    height: 124.17,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          left: 235 / 2 - 120 / 2,
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withOpacity(0.5),
                            radius: 15,
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageMetaData(),
                                    // SpecificQuadrat(
                                    //     allData: allData,
                                    //     projectID: projectID,
                                    //     quadratID: quadratID),
                                  ),
                                );
                              },
                              icon: const PhosphorIcon(
                                PhosphorIconsRegular.cameraPlus,
                                color: Color.fromARGB(255, 255, 255, 255),
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              allData['quadrat_name'] ?? 'N/A',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              allData['quadrat_description'] ?? 'N/A',
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                color: const Color.fromARGB(255, 8, 82, 10),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Positioned(
                          top: 10, // Adjust the top position as needed
                          right: 10,

                          child: PopupMenuButton<String>(
                            icon: const PhosphorIcon(
                                PhosphorIconsBold.dotsThreeOutlineVertical),
                            iconSize: 17,
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit Quadrat'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete Quadrat'),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'delete') {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Are you sure to delete quadrat?',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      content: Text(
                                        'This action cannot be undone.',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text(
                                            'Cancel',
                                            style: GoogleFonts.poppins(
                                              color: Colors.blue,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text(
                                            'Confirm',
                                            style: GoogleFonts.poppins(
                                              color: Colors.red,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          onPressed: () async {
                                            await LocalDatabase().deleteQuadrat(
                                                quadratid: quadratID);
                                            // print('Quadrat deleted');
                                            onDelete(); // Call the callback to notify the parent
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Edit Quadrat'),
                                      content: const Text(
                                          'This action cannot be undone.'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('Confirm'),
                                          onPressed: () {
                                            // Implement actual deletion logic here
                                            // print('Quadrat Edited');
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            offset: const Offset(0, 30),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Latitude: ${allData['latitude'] ?? 'N/A'}",
                    style: GoogleFonts.poppins(fontSize: 9),
                  ),
                  Text(
                    "Longitude: ${allData['longitude'] ?? 'N/A'}",
                    style: GoogleFonts.poppins(fontSize: 8),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _loadData() async {
    final data = await LocalDatabase().readData();
    return data;
  }
}
