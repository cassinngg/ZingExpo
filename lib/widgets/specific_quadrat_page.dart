// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:zingexpo/database/database.dart';
// import 'package:zingexpo/widgets/card_ginger.dart';
// import 'package:zingexpo/widgets/heading_quadrat.dart';
// import 'package:zingexpo/widgets/open_projects.dart';
// import 'package:zingexpo/widgets/quadratcarddesign.dart';

// class SpecificQuadrat extends StatefulWidget {
//   final Map<String, dynamic> allData;
//   final int quadratID;

//   const SpecificQuadrat({
//     required this.allData,
//     required this.quadratID,
//   });

//   @override
//   State<SpecificQuadrat> createState() => _SpecificQuadratState();
// }

// class _SpecificQuadratState extends State<SpecificQuadrat> {
//   // late Future<List<Map<String, dynamic>>> _projectsFuture;
//   List<Map<String, dynamic>> allData = [];
//   bool _isLoading = true;
//   List quadratData = []; // Store the quadrats for the selected project
//   bool isLoading = true;

//   Future<void> _loadData() async {
//     try {
//       final data = await LocalDatabase().readData();
//       setState(() {
//         allData = data;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       // Handle error (show dialog, log, etc.)
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//     _fetchGingerFromQuadrats();
//   }

//   Future<void> _fetchGingerFromQuadrats() async {
//     final quadratID =
//         widget.allData['quadrat_id']; // Get the selected project ID
//     if (quadratID != null) {
//       // Fetch quadrats using the project ID
//       quadratData =
//           await LocalDatabase().getGingersFromQuadrats(quadratID as int);
//     }
//     setState(() {
//       isLoading = false; // Loading done
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [],
//         iconTheme: const IconThemeData(
//           color: Colors.black,
//         ),
//         bottom: PreferredSize(
//           preferredSize: Size.fromHeight(50.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
//                 child: HeadingQuadrat(
//                   title: widget.allData['quadrat_name'] ?? 'N/A',
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           alignment: Alignment.centerLeft,
//           margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 13),
//               Container(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Species Found",
//                   style: GoogleFonts.poppins(
//                       color: Colors.black,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600),
//                 ),
//               ),
//               SizedBox(height: 13),
//             ListView(
//               children: [
//                 const SizedBox(height: 10),
//                 Container(
//                   margin: const EdgeInsets.fromLTRB(30, 0, 10, 0),
//                   child: Text(
//                     "Projects",
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   alignment: Alignment.topLeft,
//                 ),
//                 allData.isNotEmpty
//                     ? CarouselSlider.builder(
//                         itemCount: allData.length,
//                         itemBuilder: (context, index, realIndex) {
//                           return quadratCardDesign(
//                             allData: allData[index],
//                             projectID: allData[index]['project_id'],
//                           ); // Pass the project data directly
//                         },
//                         options: CarouselOptions(
//                           height: 260,
//                           autoPlay: false,
//                           aspectRatio: 3.0,
//                           enlargeCenterPage: true,
//                           viewportFraction: 0.5,
//                           enableInfiniteScroll: true,
//                         ),
//                       )
//                     : Center(
//                         child: Text(
//                             "No recent projects available.")), // Message if no data
//                 const SizedBox(height: 10),
//               Text(
//                 "Identified Ginger",
//                 style: GoogleFonts.poppins(
//                     color: Colors.black,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600),
//               ),
//               SizedBox(height: 10),
//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 itemCount: quadratData.length,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 20,
//                   childAspectRatio: .85,
//                 ),
//                 itemBuilder: (BuildContext context, int index) {
//                   return quadratData.isNotEmpty
//                       ? GingerCard(
//                           allData: quadratData[index],
//                         )
//                       : Center(
//                           child: Text("No Quadrats created for this project"),
//                         );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.all(Radius.circular(50)),
//           boxShadow: [
//             BoxShadow(color: Colors.white, spreadRadius: 0, blurRadius: 10),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(50.0),
//             topRight: Radius.circular(50.0),
//           ),
//           child: Theme(
//             data: Theme.of(context).copyWith(
//               canvasColor: const Color.fromARGB(255, 3, 70, 6),
//               primaryColor: const Color.fromARGB(255, 255, 255, 255),
//               textTheme: Theme.of(context)
//                   .textTheme
//                   .copyWith(caption: TextStyle(color: Colors.yellow)),
//             ),
//             child: BottomNavigationBar(
//               type: BottomNavigationBarType.fixed,
//               items: const <BottomNavigationBarItem>[
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.add, size: 30),
//                   label: 'Add Quadrat',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.home, size: 30),
//                   label: '',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.camera, size: 30),
//                   label: '',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.arrow_back, size: 30),
//                   label: '',
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/sample/file_access.dart';
import 'package:zingexpo/screens/BottomNavigationBars/camera_identify.dart';
import 'package:zingexpo/widgets/card_ginger.dart';
import 'package:zingexpo/widgets/heading_quadrat.dart';
import 'package:zingexpo/widgets/quadratcarddesign.dart';

class SpecificQuadrat extends StatefulWidget {
  final Map<String, dynamic> allData;
  final int projectID;
  final int quadratID;

  const SpecificQuadrat({
    super.key, // Added key parameter for better widget tree management
    required this.allData,
    required this.quadratID,
    required this.projectID,
  });

  @override
  State<SpecificQuadrat> createState() => _SpecificQuadratState();
}

class _SpecificQuadratState extends State<SpecificQuadrat> {
  List<Map<String, dynamic>> allData = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> quadratData =
      []; // Store the quadrats for the selected project

  @override
  void initState() {
    super.initState();
    _loadData();
    _fetchGingerFromQuadrats();
  }

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

  Future<void> _fetchGingerFromQuadrats() async {
    final quadratID = widget.quadratID;
    // final projectID = widget.allData;
    // Fetch ginger data using the quadrat ID
    quadratData = await LocalDatabase().getGingersFromQuadrats(quadratID);
    setState(() {
      _isLoading = false; // Loading done
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: HeadingQuadrat(
                  title: widget.allData['quadrat_name'] ?? 'N/A',
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
              child: Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 13),
                    Text(
                      "Identified Ginger",
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    allData.isNotEmpty
                        ? Container(
                            margin: EdgeInsets.zero, // Ensure no margin
                            child: CarouselSlider.builder(
                              itemCount: allData.length,
                              itemBuilder: (context, index, realIndex) {
                                return Container(
                                  margin: EdgeInsets
                                      .zero, // Ensure no margin for each item
                                  child: QuadratCardDesign(
                                    allData: allData[index],
                                    projectID: allData[index]['project_id'],
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                height: 260.0, // Set a fixed height if needed
                                aspectRatio: 1.75,
                                viewportFraction:
                                    .60, // Display one item at a time
                                initialPage: 0,
                                enableInfiniteScroll:
                                    false, // Disable infinite scrolling
                                reverse: false,
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 3),
                                autoPlayAnimationDuration:
                                    const Duration(milliseconds: 800),
                                autoPlayCurve: Curves.fastOutSlowIn,
                                enlargeCenterPage:
                                    false, // Disable center page enlargement
                                enlargeFactor:
                                    0.0, // Set enlargement factor to 0
                                padEnds: false, // Disable padding at ends
                                // Disable center page centering
                                scrollDirection: Axis.horizontal,
                              ),
                            ),
                          )
                        : const Center(
                            child: Text("No recent projects available.")),
                    const SizedBox(height: 10),
                    Text(
                      "Identified Sub-family",
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: quadratData.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 20,
                        childAspectRatio: .85,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return quadratData.isNotEmpty
                            ? GingerCard(
                                allData: quadratData[index],
                              )
                            : const Center(
                                child: Text(
                                    "No Quadrats created for this project"), // Message if no data
                              );
                      },
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProjectShareExample(
                          projectData: {
                            'project_id': widget.projectID,
                            'project_name': widget.allData['project_name'],
                            'project_description':
                                widget.allData['project_description'],
                            'project_location':
                                widget.allData['project_location'],
                          },
                          projectID: widget.projectID,
                        )),
              );
            },
            backgroundColor: const Color.fromARGB(255, 8, 82, 10),
            child: const Icon(
              Icons.camera,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          // Positioned(
          //   top: -20, // Adjust the position as needed
          //   child: Text(
          //     'Add New Project',
          //     style: TextStyle(
          //       color: Colors.white,
          //       fontSize: 16,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
