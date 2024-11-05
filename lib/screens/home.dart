import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/location/location.dart';
import 'package:zingexpo/widgets/home_tabs/archive_tab.dart';
import 'package:zingexpo/widgets/home_tabs/projects_tab.dart';
// Uncomment the next line if you actually need to use DatabaseService
// import 'package:zingexpo/database/database.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController gingerName = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> allData = [];
  // bool _isLoading = true;
  // final bool _isSearching = false;
  String _locationMessage = "Getting location...";

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

  // void _toggleSearchMode() {
  //   setState(() {
  //     _isSearching = !_isSearching;
  //     if (!_isSearching) {
  //       filteredData = List.from(allData);
  //     }
  //   });
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   _initDatabase();
  // }
  @override
  void initState() {
    super.initState();
    _loadData();
    _getLocation();

    getCurrentLocation();
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location Services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permission are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location Services are permanently denied, we cannot request Lcoation.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getLocation() async {
    LocationService locationService = LocationService();
    try {
      LocationData locationData = await locationService.getCurrentLocation();
      setState(() {
        _locationMessage =
            "Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude}";
      });
    } catch (e) {
      setState(() {
        _locationMessage = e.toString();
      });
    }
  }
  // Future<void> _initDatabase() async {
  //   try {
  //     await LocalDatabase().database;
  //     print('Database initialized successfully');
  //   } catch (e) {
  //     print('Error initializing database: $e');
  //   }
  // }

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
        child: Container(
          child: const Column(
            children: [
              Expanded(child: HomeProjectsTab()),
              // Expanded(child: HomeArchivesTab()),
            ],
          ),
        ),
      ),
    );
  }

  // void _performSearch() {
  //   if (_isSearching) {
  //     final searchTerm = searchController.text.toLowerCase();
  //     setState(() {
  //       filteredData = allData.where((item) {
  //         return item['project_name'].toLowerCase().contains(searchTerm) ||
  //             item['project_description'].toLowerCase().contains(searchTerm);
  //       }).toList();
  //     });
  //   } else {
  //     setState(() {
  //       filteredData = List.from(allData);
  //     });
  //   }
  // }
}
