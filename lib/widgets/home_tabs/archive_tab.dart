import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/design/card_design.dart';
import 'package:zingexpo/design/logo.dart';
import 'package:zingexpo/screens/add_project.dart';
// Uncomment the next line if you actually need to use DatabaseService
// import 'package:zingexpo/database/database.dart';

class HomeArchivesTab extends StatefulWidget {
  const HomeArchivesTab({super.key});

  @override
  State<HomeArchivesTab> createState() => _HomeArchivesTabState();
}

class _HomeArchivesTabState extends State<HomeArchivesTab> {
  final TextEditingController gingerName = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> allData = [];
  // bool _isLoading = true;
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
        // _isLoading = false;
      });
    } catch (e) {
      setState(() {
        // _isLoading = false;
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
              // backgroundColor: Colors.transparent,
              ),
        ),
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              // backgroundColor: Colors.transparent,
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
                preferredSize: const Size.fromHeight(120.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PreferredSize(
                      preferredSize: const Size.fromHeight(60.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 2, 10, 0),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50.0),
                                    borderSide: BorderSide.none),
                                suffixIcon: IconButton(
                                  icon: const PhosphorIcon(
                                    PhosphorIconsRegular.magnifyingGlass,
                                    color: const Color.fromARGB(255, 8, 82, 10),
                                  ),
                                  onPressed: () {
                                    // Trigger search here
                                    _performSearch();
                                  },
                                ),
                                hintText: 'Search Project',
                                fillColor: Color.fromARGB(255, 245, 245, 245),
                                // fillColor: Colors.green.withOpacity(.2),
                                contentPadding: const EdgeInsets.fromLTRB(
                                    10.0, 15.0, 20.0, 15.0),
                                filled: true,
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w100,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    ),
                    TabBar(
                      indicatorColor: Colors.green.shade900,
                      labelColor: Colors.green.shade900,
                      // splashBorderRadius: BorderRadius.circular(10),
                      unselectedLabelColor: Colors.grey.shade600,

                      // indicatorWeight: .1,
                      // indicatorPadding: EdgeInsets.zero, // or a smaller value

                      // indicatorPadding: const EdgeInsets.fromLTRB(70, 0, 70, 0),
                      tabs: const [
                        Tab(
                          text: "Projects",
                        ),
                        Tab(
                          text: "Archived",
                        ),
                        Tab(
                          text: "",
                        ),
                      ],
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                      ),
                      unselectedLabelStyle: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: archiveBody(),
          ),
        ),
      ),
    );
  }

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

  Widget _buildCarousel() {
    if (_isSearching) {
      return CarouselSlider.builder(
        itemCount: filteredData.length,
        itemBuilder: (context, index, realIndex) {
          return CardDesign(
            allData: filteredData[index],
            projectID: filteredData[index]['project_id'],
          );
        },
        options: CarouselOptions(
          height: 320,
          autoPlay: false,
          aspectRatio: 3.0,
          viewportFraction: 0.63,
          enableInfiniteScroll: true,
        ),
      );
    } else {
      return CarouselSlider.builder(
        itemCount: allData.length,
        itemBuilder: (context, index, realIndex) {
          return CardDesign(
            allData: allData[index],
            projectID: allData[index]['project_id'],
          );
        },
        options: CarouselOptions(
          height: 320,
          autoPlay: false,
          aspectRatio: 3.0,
          viewportFraction: 0.63,
          enableInfiniteScroll: true,
        ),
      );
    }
  }

  Widget archiveBody() {
    return ListView(
      children: [
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.fromLTRB(30, 0, 10, 0),
          child: Text(
            "Archives",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          alignment: Alignment.topLeft,
        ),
        _buildCarousel(),
        const SizedBox(height: 20),
        Container(
          margin: const EdgeInsets.fromLTRB(30, 0, 10, 0),
          child: Text("Recent Open Project",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              )),
          alignment: Alignment.topLeft,
        ),
        // _buildListView(),
      ],
    );
  }
}
