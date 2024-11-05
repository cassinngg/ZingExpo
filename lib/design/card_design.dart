import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/sample/bottomnavbarsample.dart';
import 'package:zingexpo/screens/project_page.dart';

class CardDesign extends StatefulWidget {
  final Map<String, dynamic> allData;
  final int projectID;
  // final VoidCallback onDelete; // Callback for deletion

  const CardDesign({
    super.key,
    required this.allData,
    required this.projectID,
    // required this.onDelete,
  });

  @override
  State<CardDesign> createState() => _CardDesignState();
}

class _CardDesignState extends State<CardDesign> {
  List<Map<String, dynamic>> allData = [];

  bool _isLoading = true;
  List<Map<String, dynamic>> quadratData = [];
  bool isLoading = true;

  Future<void> _loadData() async {
    try {
      final data = await LocalDatabase().readData();
      setState(() {
        allData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error (show dialog, log, etc.)
    }
  }

  Future<void> _fetchProjects() async {
    final projectID =
        widget.allData['project_id']; // Get the selected project ID

    _loadData();

    setState(() {
      isLoading = false; // Loading done
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    // final currentProject = widget.allData[widget.index];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FloatingSample(
                    allData: widget.allData,
                    projectID: widget.projectID,
                    onDelete: () {
                      _fetchProjects(); // Fetch the updated list
                    },
                  )),
        );
      },
      // child: Container(
      //   decoration: BoxDecoration(
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.black.withOpacity(0.15),
      //         blurRadius: 1,
      //         offset: Offset(0, 0),
      //       ),
      //     ],
      //   ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          // width: 400,
          // height: 400,
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Color.fromARGB(255, 250, 250, 250),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: widget.allData['project_image'] != null
                              ? Center(
                                  child: Image.memory(
                                    widget.allData['project_image']!,
                                    width: 226,
                                    height: 192,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Center(
                                  child: Image.asset(
                                    "assets/zingiber_zerumbet.jpg", // Use Image.asset for local images
                                    width: 226,
                                    height: 192,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.allData['project_name'] ?? 'N/A',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Row(
                          children: [
                            const PhosphorIcon(
                              PhosphorIconsRegular.flowerLotus,
                              color: Color(0xFF023C0E),
                              // White color
                              size: 20,
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            const Padding(padding: EdgeInsets.only(top: 60)),
                            Text(
                              widget.allData['project_description'].length > 6
                                  ? widget.allData['project_description']
                                          .substring(0, 6) +
                                      '...'
                                  : widget.allData['project_description'],
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                color: const Color(0xFF023C0E),
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Spacer(
                              flex: 1,
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 10,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                  Text(
                                    "20",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                    ),
                                    // textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
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

      // ),
    );
  }
}
