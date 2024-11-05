import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuadratCardDesign extends StatelessWidget {
  final Map<String, dynamic> allData;
  final int projectID;
  // final int quadratID;

  const QuadratCardDesign({super.key, 
    required this.allData,
    required this.projectID,
    // required this.quadratID,
  });
  // Initialize the project data
  @override
  Widget build(BuildContext context) {
    // final currentProject = widget.allData[widget.index];

    return InkWell(
      // onTap: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => SpecificProjectSample(
      //               allData: allData,
      //               projectID: projectID,
      //             )),
      //   );
      // },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 200,
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: const Color(0xFFF0F0F0),
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: allData['quadrat_image'] != null
                              ? Image.memory(allData['quadrat_image']!,
                                  width: 200, height: 150, fit: BoxFit.cover)
                              : Center(
                                  child: Image.asset(
                                    "assets/zingiber_zerumbet.jpg", // Use Image.asset for local images
                                    width: 200,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),

                      // Positioned widgets remain unchanged
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          allData['species_id'] ?? 'N/A',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.grass_outlined,
                              size: 10,
                              color: Color.fromARGB(255, 10, 14, 11),
                            ),
                            Text(
                              allData['observation_date'] ?? 'N/A',
                              style: GoogleFonts.poppins(fontSize: 10),
                            ),
                            const SizedBox(width: 20),
                            const Icon(
                              Icons.camera_alt_outlined,
                              size: 10,
                              color: Color(0xFF023C0E),
                            ),
                            Text(
                              "20",
                              style: GoogleFonts.poppins(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
