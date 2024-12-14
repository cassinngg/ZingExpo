import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/widgets/quadratcarddesign.dart';

class SpecificQuadrat extends StatefulWidget {
  final Map<String, dynamic> allData;
  final int projectID;
  final int quadratID;

  const SpecificQuadrat({
    super.key,
    required this.allData,
    required this.quadratID,
    required this.projectID,
  });

  @override
  State<SpecificQuadrat> createState() => _SpecificQuadratState();
}

class _SpecificQuadratState extends State<SpecificQuadrat>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allData = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> quadratData = [];
  List<Map<String, dynamic>> infos = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadData();
    _fetchGingerFromQuadrats();
    _fetchIdentifiedSpecies();
    _tabController = TabController(length: 2, vsync: this);
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
    }
  }

  Future<void> _fetchIdentifiedSpecies() async {
    try {
      final quadratid = widget.quadratID;
      infos = await LocalDatabase()
          .getIdentifiedSpeciesByProjectAndQuadrat(quadratid);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching identified species: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchGingerFromQuadrats() async {
    final quadratID = widget.quadratID;
    quadratData = await LocalDatabase().getGingersFromQuadrats(quadratID);
    setState(() {
      _isLoading = false; // Loading done
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 58, 56, 56),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Text(
                        widget.allData['quadrat_name'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: "Identified"),
                  Tab(text: "Unidentified"),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Identified Species Tab
                _buildIdentifiedSpeciesTab(),
                // Unidentified Species Tab
                _buildUnidentifiedSpeciesTab(),
              ],
            ),
    );
  }

  Widget _buildIdentifiedSpeciesTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          const Text(
            "Identified Ginger",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 18),
          if (infos.isNotEmpty &&
              infos[0]['image_name'] == '10 Unidentified Specie')
            const Center(
              child: Text(
                "There are no identified species.",
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
              ),
            )
          else
            CarouselSlider.builder(
              itemCount: infos.length,
              itemBuilder:
                  (BuildContext context, int realIndex, int pageViewIndex) {
                return QuadratCardDesign(
                  allData: infos[realIndex],
                  projectID: widget.projectID,
                  quadratID: widget.quadratID,
                  infos: infos[realIndex],
                );
              },
              options: CarouselOptions(
                height: 320,
                autoPlay: false,
                aspectRatio: 3.0,
                viewportFraction: 0.63,
                enableInfiniteScroll: false,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUnidentifiedSpeciesTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          const Text(
            "Unidentified Ginger",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 18),
          if (infos.isNotEmpty &&
              infos[0]['image_name'] == '10 Unidentified Specie')
            CarouselSlider.builder(
              itemCount: infos.length,
              itemBuilder:
                  (BuildContext context, int realIndex, int pageViewIndex) {
                return QuadratCardDesign(
                  allData: infos[realIndex],
                  projectID: widget.projectID,
                  quadratID: widget.quadratID,
                  infos: infos[realIndex],
                );
              },
              options: CarouselOptions(
                height: 320,
                autoPlay: false,
                aspectRatio: 3.0,
                viewportFraction: 0.63,
                enableInfiniteScroll: false,
              ),
            )
          else
            const Center(
              child: Text(
                "There are unidentified species.",
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
              ),
            )
        ],
      ),
    );
  }
}
