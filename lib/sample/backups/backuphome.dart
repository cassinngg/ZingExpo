import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/design/card_design.dart';
import 'package:zingexpo/design/logo.dart';
import 'package:zingexpo/screens/BottomNavigationBars/camera_identify.dart';
import 'package:zingexpo/screens/homepage_screens/open_projects.dart';
// Uncomment the next line if you actually need to use DatabaseService
// import 'package:zingexpo/database/database.dart';

class BackupHome extends StatefulWidget {
  const BackupHome({super.key});

  @override
  State<BackupHome> createState() => _BackupHomeState();
}

class _BackupHomeState extends State<BackupHome> {
  final TextEditingController gingerName = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> allData = [];
  bool _isLoading = true;
  bool _isSearching = false;
  List<Map<String, dynamic>> filteredData = [];
  // Uncomment the next line if you actually need to use DatabaseService
  // final DatabaseService _databaseService = DatabaseService.instance;

  Future<void> _loadData() async {
    try {
      final data = await LocalDatabase().readData();
      setState(() {
        allData = data;
        filteredData = List.from(data); // Create a copy of allData
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error (show dialog, log, etc.)
    }
  }

  void _toggleSearchMode() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        filteredData = List.from(allData);
      }
    });
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

  Future<void> _initDatabase() async {
    try {
      await LocalDatabase().database;
      print('Database initialized successfully');
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Theme(
        data: ThemeData(
          primaryColor: Colors.green.shade900,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
          ),
        ),
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: () {
                    // Navigate to the input page
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => AddProject()),
                    // );
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Colors.green,
                    size: 30,
                  ),
                  color: Colors.transparent.withOpacity(.5),
                ),
              ],
              title: const Row(
                children: [
                  Logo(),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(100.0),
                child: Column(
                  children: [
                    PreferredSize(
                      preferredSize: const Size.fromHeight(60.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50.0),
                                    borderSide: BorderSide.none),
                                suffixIcon: IconButton(
                                  icon: const PhosphorIcon(
                                      PhosphorIconsRegular.magnifyingGlass),
                                  onPressed: () {
                                    // Trigger search here
                                    _performSearch();
                                  },
                                ),
                                hintText: 'Search Project',
                                fillColor: Colors.green.withOpacity(.2),
                                contentPadding: const EdgeInsets.fromLTRB(
                                    10.0, 15.0, 20.0, 15.0),
                                filled: true,
                              ),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TabBar(
                      indicatorColor: Colors.green.shade900,
                      labelColor: Colors.green.shade900,
                      unselectedLabelColor: Colors.grey.shade600,
                      indicatorWeight: 3,
                      indicatorPadding: EdgeInsets.zero, // or a smaller value

                      // indicatorPadding: const EdgeInsets.fromLTRB(70, 0, 70, 0),
                      tabs: const [
                        Tab(
                          text: "Projects",
                        ),
                        Tab(
                          text: "Archived",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            body: ListView(
              children: [
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.fromLTRB(30, 0, 10, 0),
                  alignment: Alignment.topLeft,
                  child: const Text(
                    "Projects",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
                // allData.isNotEmpty
                //     ? CarouselSlider.builder(
                //         itemCount: allData.length,
                //         itemBuilder: (context, index, realIndex) {
                //           return CardDesign(
                //             allData: allData[index],
                //             projectID: allData[index]['project_id'],
                //           ); // Pass the project data directly
                //         },
                //         options: CarouselOptions(
                //           height: 320,
                //           autoPlay: false,
                //           aspectRatio: 3.0,

                //           // enlargeCenterPage: true,
                //           viewportFraction: .63,
                //           enableInfiniteScroll: true,
                //         ),
                //       )
                //     : const Center(
                //         child: Text(
                //             "No recent projects available.")), // Message if no data
                // const SizedBox(height: 20),
                // Container(
                //   margin: const EdgeInsets.fromLTRB(30, 0, 10, 0),
                //   alignment: Alignment.topLeft,
                //   child: const Text(
                //     "Recent Open Project",
                //     style: TextStyle(
                //       fontWeight: FontWeight.w600,
                //       fontSize: 13,
                //     ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: allData.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: allData.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(
                                        0xFFEAEAEA), // Change this to your desired color
                                    width: 1.0, // Adjust the width as needed
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: OpenProjects(
                                  allData: allData[index],
                                  projectID: allData[index]['project_id'],
                                ),
                              ),
                            );
                          },
                        )
                      : const Text('No data available'),
                )
                // Padding(
                //   padding: const EdgeInsets.all(10.0),
                //   child: allData.isNotEmpty
                //       ? Column(
                //           children: allData.map((projectData) {
                //             return cardDesign(
                //               allData: allData[
                //                   index], projectID: allData[index]['project_id'],); // Pass individual project data
                //           }).toList(),
                //         )
                //       : Center(
                //           child: Text("No recent projects available."),
                //         ),
                // ),
              ],
            ),
            floatingActionButton: Stack(
              alignment: Alignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RealtimeCamScreen()),
                    );
                  },
                  child: const Icon(
                    Icons.add,
                    color: Color.fromARGB(255, 8, 82, 10),
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
          ),
        ),
      ),
    );
  }

  // void _performSearch() {
  //   final searchTerm = searchController.text.toLowerCase();
  //   setState(() {
  //     allData = allData.where((item) {
  //       return item['project_name'].toLowerCase().contains(searchTerm) ||
  //           item['project_description'].toLowerCase().contains(searchTerm);
  //     }).toList();
  //   });
  // }
  void _performSearch() {
    if (_isSearching) {
      final searchTerm = searchController.text.toLowerCase();
      setState(() {
        filteredData = allData.where((item) {
          return item['project_name'].toLowerCase().contains(searchTerm) ||
              item['project_description'].toLowerCase().contains(searchTerm);
        }).toList();
      });
    } else {
      setState(() {
        filteredData = List.from(allData);
      });
    }
  }
}
