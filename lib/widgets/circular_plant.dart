import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/widgets/circle_info.dart';

class CircularPlant extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String plantId;

  const CircularPlant({super.key, 
    required this.title,
    required this.imageUrl,
    required this.plantId,
  });

  @override
  State<CircularPlant> createState() => _CircularPlantState();
}

class _CircularPlantState extends State<CircularPlant> {
  // Map<String, dynamic>? currentPlantDetails;
  List<Map<String, dynamic>> allData = [];
  // bool _isLoading = true;
  // Uncomment the next line if you actually need to use DatabaseService
  // final DatabaseService _databaseService = DatabaseService.instance;

  Future<void> _loadData() async {
    try {
      final data = await LocalDatabase().readData();
      setState(() {
        allData = data;
        // _isLoading = false;
      });
    } catch (e) {
      setState(() {
        // _isLoading = false;
      });
      // Handle error (show dialog, log, etc.)
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _initDatabase();
  // }
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          // Check if plantId is not empty
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CircleInfoPage(plantId: widget.plantId)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 48, // Adjust the radius as needed
                backgroundImage: AssetImage(widget.imageUrl),
              ),
              Text(
                widget.title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}























// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_fonts/google_fonts.dart';

// class CircularPlant extends StatelessWidget {
//   final String genusName;
//   final String growthAndStructure;
//   final String habitat;
//   final String imageUrl;

//   CircularPlant({
//     required this.genusName,
//     required this.growthAndStructure,
//     required this.habitat,
//     required this.imageUrl,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: InkWell(
//         onTap: () {
//           // Implement navigation or action here
//         },
//         child: Container(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CircleAvatar(
//                   radius: 48, // Adjust the radius as needed
//                   backgroundImage: NetworkImage(imageUrl),
//                 ),
//                 Text(
//                   genusName,
//                   style: GoogleFonts.poppins(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Text(
//                   growthAndStructure,
//                   style: GoogleFonts.poppins(
//                     fontSize: 10,
//                     fontWeight: FontWeight.normal,
//                   ),
//                 ),
//                 Text(
//                   habitat,
//                   style: GoogleFonts.poppins(
//                     fontSize: 10,
//                     fontWeight: FontWeight.normal,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
