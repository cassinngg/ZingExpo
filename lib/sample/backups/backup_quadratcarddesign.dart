// import 'package:flutter/material.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import 'package:zingexpo/database/database.dart';
// import 'package:zingexpo/screens/specific_project_Screens/specific_project_screen.dart';

// class QuadratCardDesign extends StatefulWidget {
//   final Map<String, dynamic> allData;
//   final Map<String, dynamic> info; // Added info parameter
//   final int projectID;
//   final int quadratID;
//   final VoidCallback onProjectUpdated;

//   QuadratCardDesign({
//     super.key,
//     required this.allData,
//     required this.info, // Initialize info
//     required this.projectID,
//     required this.onProjectUpdated,
//     required this.quadratID,
//   });

//   @override
//   State<QuadratCardDesign> createState() => _QuadratCardDesignState();
// }

// class _QuadratCardDesignState extends State<QuadratCardDesign> {
//   List<Map<String, dynamic>> allData = [];
//   bool _isLoading = true;
//   List<Map<String, dynamic>> identifiedSpecies = [];
//   bool isLoading = true;

//   // void _onProjectUpdated(Map<String, dynamic> updatedData) {
//   //   setState(() {
//   //     widget.allData = updatedData;
//   //   });
//   //   _fetchProjects();
//   // }

//   Future<void> _fetchIdentifiedSpecies() async {
//     try {
//       identifiedSpecies =
//           await LocalDatabase().getIdentifiedSpeciesByProjectAndQuadrat(
//         widget.projectID,
//         widget.quadratID,
//       );
//       setState(() {
//         isLoading = false;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching identified species: $e')),
//       );
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _loadData() async {
//     try {
//       final data = await LocalDatabase().readData();
//       await _fetchIdentifiedSpecies();
//       setState(() {
//         allData = data;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchProjects() async {
//     _loadData();
//     setState(() {
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => SpecificProjectsPage(
//               allData: widget.allData,
//               projectID: widget.projectID,
//               onDelete: () {
//                 _fetchProjects();
//               },
//               onProjectUpdated: () {},
//             ),
//           ),
//         );
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(5),
//         child: ClipRRect(
//           child: Card(
//             elevation: 5,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//             color: Color(0xFFffffff),
//             child: Padding(
//               padding: const EdgeInsets.only(left: 8, right: 8),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Stack(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: widget.info['image_path'] != null
//                               ? Center(
//                                   child: Image.memory(
//                                     widget.info['image_path']!,
//                                     width: 226,
//                                     height: 192,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 )
//                               : Center(
//                                   child: Image.asset(
//                                     "assets/zingiber_zerumbet.jpg",
//                                     width: 226,
//                                     height: 192,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 5,
//                         right: 10,
//                         child: Row(
//                           children: [
//                             Container(
//                               height: 40,
//                               decoration: const BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Color(0xFFffffff),
//                               ),
//                               child: Center(
//                                 child: IconButton(
//                                   onPressed: () {},
//                                   icon: const PhosphorIcon(
//                                     PhosphorIconsRegular.upload,
//                                     color: Color(0xFF023C31),
//                                     size: 20,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               width: 70,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(100),
//                                 color: const Color(0xFFffffff),
//                               ),
//                               child: Center(
//                                 child: IconButton(
//                                   onPressed: () {},
//                                   icon: const PhosphorIcon(
//                                     PhosphorIconsRegular.cameraPlus,
//                                     color: Color(0xFF023C31),
//                                     size: 20,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.allData['project_name'] ?? 'N/A',
//                           style: const TextStyle(
//                             fontFamily: 'Poppins',
//                             fontWeight: FontWeight.w600,
//                             fontSize: 12,
//                           ),
//                           textAlign: TextAlign.left,
//                         ),
//                         Row(
//                           children: [
//                             const PhosphorIcon(
//                               PhosphorIconsRegular.flowerLotus,
//                               color: Color(0xFF023C0E),
//                               size: 20,
//                             ),
//                             const SizedBox(width: 3),
//                             Text(
//                               (widget.allData['project_description']?.length ??
//                                           0) >
//                                       15
//                                   ? widget.allData['project_description']
//                                           .substring(0, 15) +
//                                       '...'
//                                   : widget.allData['project_description'] ?? '',
//                               style: const TextStyle(
//                                 fontFamily: 'Poppins',
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF023C0E),
//                               ),
//                             ),
//                             const SizedBox(width: 20),
//                             const Spacer(flex: 1),
//                             const Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 Icon(
//                                   Icons.camera_alt_outlined,
//                                   size: 10,
//                                   color: Color.fromARGB(255, 0, 0, 0),
//                                 ),
//                                 Text(
//                                   "20",
//                                   style: TextStyle(
//                                     fontFamily: 'Poppins',
//                                     fontSize: 10,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
