import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/screens/BottomNavigationBars/camera_identify.dart';
import 'package:zingexpo/screens/BottomNavigationBars/share_quadrat.dart';
import 'package:zingexpo/screens/add_quadrats.dart';
import 'package:zingexpo/screens/home.dart';
import 'package:zingexpo/widgets/card_quadrat.dart';
import 'package:zingexpo/widgets/circular_plant.dart';
import 'package:zingexpo/widgets/heading_page.dart';

class NavbarSample extends StatefulWidget {
  final Map<String, dynamic> allData;
  final int projectID;
  NavbarSample({required this.allData, required this.projectID});

  @override
  State<NavbarSample> createState() => _NavbarSampleState();
}

class _NavbarSampleState extends State<NavbarSample> {
  int _currentIndex = 0;
  List<Widget> body = const [
    Icon(Icons.add),
    Icon(Icons.home),
    Icon(Icons.camera_alt_outlined),
    Icon(Icons.screen_share_outlined)
  ];
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

  @override
  void initState() {
    super.initState();
    _loadData();
    _fetchQuadrats();
  }

  Future<void> _fetchQuadrats() async {
    final projectID =
        widget.allData['project_id']; // Get the selected project ID
    if (projectID != null) {
      // Fetch quadrats using the project ID
      quadratData =
          await LocalDatabase().getQuadratsByProjectID(projectID as int);
    }
    setState(() {
      isLoading = false; // Loading done
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: Obx(
        () => NavigationBar(
          backgroundColor: Colors.green.shade900,
          indicatorColor: Colors.white,
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          destinations: const [
            NavigationDestination(
              label: 'Add Quadrat',
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            NavigationDestination(
              label: ('Home'),
              icon: Icon(
                Icons.home,
                color: Colors.white,
              ),
            ),
            NavigationDestination(
              label: 'Camera',
              icon: Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
              ),
            ),
            NavigationDestination(
                label: 'Share',
                icon: Icon(
                  Icons.screen_share_outlined,
                  color: Colors.white,
                ))
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Edit Project Unavailable")));
              print('Edit button pressed');
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirm Deletion'),
                    content:
                        Text('Are you sure you want to delete this project?'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      // TextButton(
                      //   child:
                      //       Text('Delete', style: TextStyle(color: Colors.red)),
                      //   onPressed: () =>
                      //       deleteDocument(widget.project['id'], context),
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
          preferredSize: Size.fromHeight(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: HeadingText(
                      title: widget.allData['project_name'] ?? 'N/A',
                      description:
                          widget.allData['project_description'] ?? 'N/A',
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
              // body[_currentIndex],
              SizedBox(height: 13),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Species Found",
                  style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
              ),

              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: allData.map((info) {
              //       return CircularPlant(
              //         title: info['genus_name'] ??
              //             'Unknown Genus', // Default value if 'genus_name' is missing
              //         imageUrl: info['imageUrl'] ?? '',
              //         plantId: info['plantId'] ?? '',

              //         // Default empty string if 'i,mageUrl' is missing
              //       );
              //     }).toList(),
              //   ),
              // ),
              SizedBox(height: 18),
              Text(
                "Quadrats",
                style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 18),
              quadratData.isNotEmpty
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: quadratData.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 20,
                        childAspectRatio: .85,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        // return QuadratCard(
                        //   allData: quadratData[index],
                        //   quadratID: quadratData[index]['quadrat_id'],
                        // );
                      },
                    )
                  : Center(
                      child: Text("No Quadrats created for this project"),
                    )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => AddQuadrat(
          //         allData: widget.allData, projectID: widget.projectID),
          //   ),
          // );
        },
        child: Icon(Icons.add, color: const Color.fromARGB(255, 8, 82, 10)),
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

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    // addQuadrat(allData: allData, projectID: projectID),
    const Home(),
    RealtimeCamScreen(),
    //  ShareQuadrat(),
  ];
}
