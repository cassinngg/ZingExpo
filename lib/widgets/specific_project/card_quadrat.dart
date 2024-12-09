import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/sample/backups/backup_metadata.dart';
import 'package:zingexpo/sample/sam.dart';
import 'package:zingexpo/screens/edit_screens/edit_quadrat.dart';
import 'package:zingexpo/screens/identify/identify_camera.dart';
import 'package:zingexpo/screens/meta_data_related/image_meta_data.dart';
import 'package:zingexpo/screens/specific_quadrat_page/specific_quadrat_page.dart';

class QuadratCard extends StatefulWidget {
  Map<String, dynamic> allData;
  final int quadratID;
  final int projectID;
  final VoidCallback onDelete; // Callback for deletion

  QuadratCard({
    super.key,
    required this.allData,
    required this.quadratID,
    required this.onDelete,
    required this.projectID,
  });

  @override
  State<QuadratCard> createState() => _QuadratCardState();
}

class _QuadratCardState extends State<QuadratCard> {
  bool _isLoading = true;
  List<Map<String, dynamic>> quadratData = [];
  bool isLoading = true;
  Future<void> _fetchQuadrats() async {
    final projectID =
        widget.allData['project_id']; // Get the selected project ID
    if (projectID != null) {
      // Fetch quadrats using the project ID
      quadratData =
          await LocalDatabase().getQuadratsByProjectID(projectID as int);
      _loadData();
    }
    setState(() {
      isLoading = false; // Loading done
    });
    _loadData();
  }

  void _onProjectUpdated(Map<String, dynamic> updatedData) {
    setState(() {
      widget.allData = updatedData; // Update the project data
    });
    _fetchQuadrats(); // Fetch the updated quadrat data
  }

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

        return Material(
          child: InkWell(
            onTap: () {
              // Navigate to the SpecificQuadrat page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SpecificQuadrat(
                    allData: widget.allData,
                    projectID: widget.projectID,
                    quadratID: widget.quadratID,
                  ),
                ),
              );
            },
            child: ClipRRect(
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
                                child: widget.allData['quadrat_image'] != null
                                    ? Image.memory(
                                        widget.allData['quadrat_image'],
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
                                        builder: (context) => ImageIdentify(
                                          projectID: widget.projectID,
                                          allData: widget.allData,
                                          quadratID: widget.quadratID,
                                        ),
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
                          Text(
                            widget.allData['quadrat_name'] ?? 'N/A',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Positioned(
                              left: 15,
                              bottom: 30,
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
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          content: Text(
                                            'This action cannot be undone.',
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text(
                                                'Cancel',
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
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
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  color: Colors.red,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              onPressed: () async {
                                                await LocalDatabase()
                                                    .deleteQuadrat(
                                                        quadratid:
                                                            widget.quadratID);
                                                widget
                                                    .onDelete(); // Call the callback to notify the parent
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else if (value == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditQuadrat(
                                          allData: widget.allData,
                                          projectID: widget.projectID,
                                          quadratID: widget.quadratID,
                                          onUpdate: (updatedData) {
                                            _onProjectUpdated(
                                                updatedData); 
                                          },
                                        ),
                                      ),
                                    );
                                    // Navigator.of(context).pushAndRemoveUntil(
                                    //   MaterialPageRoute(
                                    //     builder: (context) => EditQuadrat(
                                    //       allData: widget.allData,
                                    //       projectID: widget.projectID,
                                    //       quadratID: widget.quadratID,
                                    //       onUpdate: (updatedData) {
                                    //         _onProjectUpdated(
                                    //             updatedData); // Update the project data
                                    //       },
                                    //     ),
                                    //   ),
                                    //   (route) => false,
                                    // );
                                    // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)), (route) => false),
                                  }
                                },
                                offset: const Offset(0, 30),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.allData['quadrat_description'] ?? 'N/A',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          color: const Color.fromARGB(255, 8, 82, 10),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Latitude: ${widget.allData['latitude'] ?? 'N/A'}",
                        style:
                            const TextStyle(fontFamily: 'Poppins', fontSize: 7),
                      ),
                      Text(
                        "Longitude: ${widget.allData['longitude'] ?? 'N/A'}",
                        style:
                            const TextStyle(fontFamily: 'Poppins', fontSize: 7),
                      ),
                    ],
                  ),
                ),
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
