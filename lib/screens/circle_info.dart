// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class CircleInfo extends StatefulWidget {
//   final String plantId; // Keep the plantId to identify which plant's details to show

//   CircleInfo({required this.plantId});

//   @override
//   State<CircleInfo> createState() => _CircleInfoState();
// }

// class _CircleInfoState extends State<CircleInfo> {
//   late Future<DocumentSnapshot<Map<String, dynamic>>> plantDetails;
//     final Map<String, dynamic> plantDetails;

//   @override
//   void initState() {
//     super.initState();
//     plantDetails = FirebaseFirestore.instance
//         .collection('ginger_information')
//         .doc(widget.plantId)
//         .get(); // Fetch the specific plant's details using its ID
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Ginger Information'),
//       ),
//       body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//         future: plantDetails,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             var data = snapshot.data!.data()!;
//             return ListView(
//               children: [
//                 ListTile(
//                   leading: Image.network(data['imageUrl']),
//                   title: Text(data['genus_name'] ?? 'Unknown Genus Name'),
//                   subtitle: Text(data['growth_and_structure'] ??
//                       'Unknown Growth Structure'),
//                 ),
//                 ListTile(
//                   leading: Text('Habitat:'),
//                   title: Text(data['habitat'] ?? 'Unknown Habitat'),
//                 ),
//                 // Add more ListTiles for other details as needed
//               ],
//             );
//           }
//         },
//       ),
//     );
//   }
// }
// circle_info_page.dart
import 'package:flutter/material.dart';

class CircleInfoPage extends StatefulWidget {
  final String plantId;

  CircleInfoPage({Key? key, required this.plantId}) : super(key: key);

  @override
  _CircleInfoPageState createState() => _CircleInfoPageState();
}

class _CircleInfoPageState extends State<CircleInfoPage> {
  Map<String, dynamic> plantDetails =
      {}; // Removed 'final' to allow reassignment
  bool isLoading = true; // Keep the loading flag

  // @override
  // void initState() {
  //   super.initState();
  //   fetchPlantDetails(widget.plantId);
  // }

  // Future<Map<String, dynamic>> fetchPlantDetails(String plantId) async {
  //   try {
  //     DocumentSnapshot<Object?> snapshot = await FirebaseFirestore.instance
  //         .collection(
  //             'ginger_information') // Ensure this is the correct collection name
  //         .doc(plantId)
  //         .get();

  //     // Check if the document exists and has data
  //     if (!snapshot.exists || snapshot.data() == null) {
  //       throw Exception('No data found for plant ID: $plantId');
  //     }

  //     Map<String, dynamic> plantDetails =
  //         snapshot.data() as Map<String, dynamic>;
  //     return plantDetails;
  //   } catch (e) {
  //     print('Error fetching plant details: $e');
  //     return {}; // Return an empty map in case of error
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Plant Details')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading
            ? Center(
                child:
                    CircularProgressIndicator()) // Show loading indicator while waiting for data
            : ListView(
                children: <Widget>[
                  Text('Genus Name: ${plantDetails['genus_name']}'),
                  Text('Habitat: ${plantDetails['habitat']}'),
                  // Add more fields as needed
                ],
              ),
      ),
    );
  }
}
