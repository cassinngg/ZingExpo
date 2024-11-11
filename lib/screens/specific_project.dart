import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zingexpo/widgets/card_quadrat.dart';
import 'package:zingexpo/widgets/heading_page.dart';

class SpecificProject extends StatefulWidget {
  final Map<String, dynamic> specificProject;
  const SpecificProject({super.key, required this.specificProject});

  @override
  State<SpecificProject> createState() => _SpecificProjectState();
}

class _SpecificProjectState extends State<SpecificProject> {
  List<Map<String, dynamic>> gingerInformation = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Edit Project Unavailable")));
              // print('Edit button pressed');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Deletion'),
                    content: const Text(
                        'Are you sure you want to delete this project?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      // TextButton(
                      //   child:
                      //       Text('Delete', style: TextStyle(color: Colors.red)),
                      //   // onPressed: () =>
                      //       // deleteDocument(widget.project['id'], context),
                      // ),
                    ],
                  );
                },
              );
            },
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: HeadingText(
                      title:
                          widget.specificProject['Name'] ?? 'Project Unnamed',
                      description: widget.specificProject['Species'] ??
                          'Species Unknown',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Identified Ginger",
                  style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Quadrats",
                style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return QuadratCard(
                    allData: gingerInformation[index],
                    quadratID: 3,
                    onDelete: () {
                      // Refresh the quadrat data after deletion
                      // _fetchQuadrats(); // Fetch the updated list
                    },
                    projectID: 1,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => Try()),
          // );
        },
        child: const Icon(Icons.add, color: Color.fromARGB(255, 8, 82, 10)),
      ),
    );
  }

  // void deleteDocument(String? documentId, BuildContext context) {
  //   if (documentId == null) {
  //     print("Document ID cannot be null.");
  //     return;
  //   }

  //   FirebaseFirestore.instance
  //       .collection('Projects')
  //       .doc(documentId)
  //       .delete()
  //       .then((_) {
  //     Navigator.pop(context);
  //     Navigator.pushReplacementNamed(context, '/home');
  //   }).catchError((error) {
  //     print("Failed to delete document: $error");
  //   });
  // }
}
