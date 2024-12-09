import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/design/logo.dart';
import 'package:zingexpo/screens/add_project.dart';
import 'package:zingexpo/screens/homepage_screens/open_projects.dart';
import 'package:zingexpo/screens/homepage_screens/project_carousel.dart';

class HomeProjectsTab extends StatefulWidget {
  const HomeProjectsTab({super.key});

  @override
  State<HomeProjectsTab> createState() => _HomeProjectsTabState();
}

class _HomeProjectsTabState extends State<HomeProjectsTab> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> allData = [];
  bool _isLoading = true;
  bool _isSearching = false;
  List<Map<String, dynamic>> filteredData = [];

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await LocalDatabase().readData();
      setState(() {
        allData = data;
        filteredData = List.from(data);
      });
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refreshData() {
    _loadData();
  }

  Future<void> _fetchProjects() async {
    final projectID = allData;

    _loadData();

    setState(() {
      _isLoading = false;
    });
    _loadData();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _fetchProjects();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Theme(
        data: ThemeData(
          primaryColor: Colors.green.shade900,
          appBarTheme: const AppBarTheme(),
        ),
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AddProject(onAdd: _refreshData)),
                    );
                    _loadData();
                  },
                  icon: const Icon(Icons.add, color: Colors.green, size: 30),
                ),
              ],
              title: const Row(
                children: [Logo()],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(120.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 2, 10, 0),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            _isSearching = value.isNotEmpty;
                            filteredData = allData
                                .where((project) => project['project_name']
                                    .toString()
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: const PhosphorIcon(
                              PhosphorIconsRegular.magnifyingGlass,
                              color: Color.fromARGB(255, 8, 82, 10),
                            ),
                            onPressed: () {
                              // Optional: You can also perform search on button press
                              setState(() {
                                _isSearching = searchController.text.isNotEmpty;
                                filteredData = allData
                                    .where((project) => project['project_name']
                                        .toString()
                                        .toLowerCase()
                                        .contains(searchController.text
                                            .toLowerCase()))
                                    .toList();
                              });
                            },
                          ),
                          hintText: 'Search Project',
                          fillColor: const Color.fromARGB(255, 245, 245, 245),
                          contentPadding:
                              const EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),
                          filled: true,
                        ),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          // color: Color(0xFF097500),
                          fontWeight: FontWeight.w100,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TabBar(
                      indicatorColor: Colors.green.shade900,
                      labelColor: Colors.green.shade900,
                      unselectedLabelColor: Colors.grey.shade600,
                      tabs: const [
                        Tab(text: "Projects"),
                        Tab(text: "Archived"),
                        Tab(text: ""),
                      ],
                      labelStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 9),
                      unselectedLabelStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 9),
                    ),
                  ],
                ),
              ),
            ),
            body:
                // _isLoading
                //     ? const Center(child: CircularProgressIndicator())
                //     :
                SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(30, 0, 10, 0),
                    alignment: Alignment.topLeft,
                    child: const Text(
                      "Projects",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ProjectCarousel(
                        projects: allData,
                        isSearching: _isSearching,
                        // projects: _isSearching ? filteredData : allData,
                        // isSearching: _isSearching,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                    alignment: Alignment.topLeft,
                    child: const Text(
                      "Recent Open Project",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allData.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFEAEAEA),
                                width: 1.0,
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
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton.extended(
              label: const Text(
                "New Project",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 9,
                  color: Color.fromARGB(255, 11, 190, 17),
                ),
              ),
              icon: const PhosphorIcon(
                PhosphorIconsRegular.plus,
                color: Color.fromARGB(255, 11, 190, 17),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddProject(onAdd: _refreshData)),
                );
                _loadData();
              },
              backgroundColor: Colors.white,
              foregroundColor: const Color.fromARGB(255, 8, 82, 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: const BorderSide(
                    color: Color.fromARGB(255, 8, 82, 10), width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
