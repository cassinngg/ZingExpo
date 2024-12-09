import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:zingexpo/screens/project_page.dart';

class OpenProjects extends StatelessWidget {
  final Map<String, dynamic> allData;
  final int projectID;

  // final int index;
  const OpenProjects(
      {super.key, required this.allData, required this.projectID});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SpecificProjectSample(
                      allData: allData,
                      projectID: projectID,
                    )),
            // SpecificProject(specificProject: projectData)),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 500,
            height: 130,
            child: Card(
              elevation: 5,
              shape: const RoundedRectangleBorder(
                  // borderRadius: BorderRadius.circular(10),
                  ),
              color: const Color(0xFFF0F0F0),
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Stack(
                  children: [
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 2),
                      child: ClipRRect(
                        // borderRadius: BorderRadius.circular(10),
                        child: allData['project_image'] != null
                            ? Image.memory(
                                allData['project_image']!,
                                width: 500,
                                height: 130,
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Image.asset(
                                  "assets/zingiber_zerumbet.jpg",
                                  width: 500,
                                  height: 130,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      bottom: 55,
                      child: SizedBox(
                        width: 55,
                        height: 35,
                        child: IconButton(
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) =>
                            //           ChooseImageScreen()),
                            // );
                          },
                          icon: const PhosphorIcon(
                            PhosphorIconsDuotone.cameraPlus,
                            color: Color.fromARGB(255, 255, 255, 255),
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 15,
                      bottom: 30,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              allData['project_name'] ?? 'N/A',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            // SizedBox(
                            //   height: 5,
                            //   width: 5,
                            // ),
                            Row(
                              children: [
                                const PhosphorIcon(
                                  PhosphorIconsRegular.flowerLotus,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  size: 25,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  allData['project_description'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 9,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            const Row(
                              children: [
                                PhosphorIcon(
                                  PhosphorIconsRegular.camera,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "20",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 9,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
