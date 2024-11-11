import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zingexpo/screens/BottomNavigationBars/bottomnavbarsample.dart';

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

//global var for easy integration data with UI
List alldatalist = [];
Database? _database;

class LocalDatabase {
  Future get database async {
    if (_database != null) return _database;
    _database = await _initializeDB('Local.db');
    return _database;
  }

  Future _initializeDB(String filepath) async {
    final dbpath = await getDatabasesPath();
    final path = join(dbpath, filepath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Projects
    await db.execute('''
  CREATE TABLE Projects(
  project_id INTEGER PRIMARY KEY AUTOINCREMENT,
  project_name TEXT NOT NULL,
  project_location TEXT,
  project_description TEXT,
  start_date DATE,
  end_date DATE,
  end INTEGER,
  project_image BLOB
  );
  ''');
    await db.execute('''
  CREATE TABLE Gingers(
  ginger_id INTEGER PRIMARY KEY AUTOINCREMENT,
  ginger_name TEXT,
  ginger_description TEXT,
  ginger_image BLOB,
  species_id INTEGER,
  FOREIGN KEY (species_id) REFERENCES Species (id)
  );
  ''');
    await db.execute('''
  CREATE TABLE Quadrats(
  quadrat_id INTEGER PRIMARY KEY AUTOINCREMENT,
  quadrat_name TEXT NOT NULL,
  elevation TEXT,
  longitude TEXT,
  latitude TEXT,
  quadrat_description TEXT,
  quadrat_image BLOB,
  project_id INTEGER,
  FOREIGN KEY (project_id) REFERENCES Projects(project_id)
  );
  ''');
    await db.execute('''
  CREATE TABLE image_meta_data(
  img_data INTEGER PRIMARY KEY AUTOINCREMENT,
  image_name TEXT NOT NULL,
  image_path TEXT,
  latitude TEXT,
  longitude TEXT,
  elevation TEXT,
  project_id INTEGER,
  quadrat_id, INTEGER,
  capture_date DATE,
  FOREIGN KEY (project_id) REFERENCES Projects(project_id),
  FOREIGN KEY (quadrat_id) REFERENCES Quadrats(quadrat_id)
  
  );
  ''');

    await db.execute('''
  CREATE TABLE specied_quadrat_mapping(
  sqm_id INTEGER PRIMARY KEY AUTOINCREMENT,
  count INTEGER,
  observation_date DATE,
  species_id INTEGER,
  quadrat_id INTEGER,
  FOREIGN KEY (species_id) REFERENCES Species (species_id),
  FOREIGN KEY (quadrat_id) REFERENCES Quadrats (quadrat_id)
  );
  ''');

    await db.execute('''
  CREATE TABLE species_collected(
  species_collected_id INTEGER PRIMARY KEY AUTOINCREMENT,
  species_name TEXT,
  common_name TEXT,
  family TEXT,
  genus TEXT,
  species_description TEXT
  );
  ''');
    await db.execute('''
  CREATE TABLE idetified_species(
  identified_species_id INTEGER PRIMARY KEY AUTOINCREMENT,
  species_collected_id INTEGER,
  species_id INTEGER,
  FOREIGN KEY (species_collected_id) REFERENCES species_collected (species_collected_id),
  FOREIGN KEY (species_id) REFERENCES Species (species_id)

  );
  ''');
    //     await db.execute('''
    // CREATE TABLE species_collected(
    // species_collected_id INTEGER PRIMARY KEY AUTOINCREMENT,
    // species_collected_name TEXT,
    // genera_id INTEGER,
    // FOREIGN KEY (genera_id) REFERENCES Generas (genera_id)
    // );
    // ''');
    await db.execute('''
  CREATE TABLE Species(
  species_id INTEGER PRIMARY KEY AUTOINCREMENT,
  species_name TEXT,
  species_description TEXT,
  sub_family TEXT,
  tribe TEXT,
  species_image BLOB,
  genera_id INTEGER,
  FOREIGN KEY (genera_id) REFERENCES Generas (genera_id)
  );
  ''');

    await db.execute('''
  CREATE TABLE Generas(
  genera_id INTEGER PRIMARY KEY AUTOINCREMENT,
  genera_name TEXT,
  tribe_id INTEGER,
  FOREIGN KEY (tribe_id) REFERENCES Tribes (tribe_id)
  );
  ''');

    await db.execute('''
  CREATE TABLE Tribes(
  tribe_id INTEGER PRIMARY KEY AUTOINCREMENT,
  tribe_name TEXT,
  subfamily_id INTEGER,
  FOREIGN KEY (subfamily_id) REFERENCES Subfamily(subfamily_id)
  );''');
    await db.execute('''
  CREATE TABLE Subfamily(
  subfamily_id INTEGER PRIMARY KEY AUTOINCREMENT,
  subfamily_name TEXT,
  family_id INTEGER,
  FOREIGN KEY (family_id) REFERENCES Family(family_id)
  );''');
    await db.execute('''

  CREATE TABLE Family(
  family_id INTEGER PRIMARY KEY AUTOINCREMENT,
  family_name TEXT
  );
  ''');
    await db.execute('''
  CREATE TABLE data_analysis(
  data_analysis_id INTEGER PRIMARY KEY AUTOINCREMENT,
  species_id INTEGER,
  quadrat_name TEXT,
  elevation TEXT,
  latitude TEXT,
  longitude TEXT,
  date_added DATE,
  shannon_index_id INTEGER,
  quadrat_id INTEGER,
  FOREIGN KEY (shannon_index_id) REFERENCES shannon_diversity_index (shannon_index_id),
  FOREIGN KEY (quadrat_id) REFERENCES Quadrats (quadrat_id)
  );
  ''');

    await db.execute('''
  CREATE TABLE shannon_diversity_index(
  shannon_index_id INTEGER PRIMARY KEY AUTOINCREMENT,
  index_name TEXT
  );
  ''');
    await db.execute('''
  CREATE TABLE mode_of_growth(
  mode_of_growth_id INTEGER PRIMARY KEY AUTOINCREMENT,
  mode_of_growth_name TEXT
  );
  ''');
    await db.execute('''
  CREATE TABLE ginger_mode_of_growth(
  ginger_id INTEGER,
  mode_of_growth_id INTEGER,
  FOREIGN KEY (ginger_id) REFERENCES Ginger (ginger_id),
  FOREIGN KEY (mode_of_growth_id) REFERENCES mode_of_growth(mode_of_growth_id)
  );
  ''');

    await db.execute('''INSERT INTO Gingers (ginger_name, ginger_description)
VALUES 
('Alpinia Haenkei', 'Alpinia is a genus of flowering plants in the ginger family, Zingiberaceae. Species are native to Asia, Australia, and the Pacific Islands, where they occur in tropical and subtropical climates. This Philippine endemic species grows in low and medium elevation forests, typically reaching heights of 1-3 meters. Its pseudostems are composed of overlapping leaf sheaths, forming a distinctive architectural feature.'),
('Adelmeria Alpina', 'As an endemic species to the Philippines, Adelmeria alpina is relatively understudied. Limited information suggests it may inhabit tropical forests, but further research is needed to confirm its ecological characteristics. Adelmeria is a genus of perennial herbs in the family Zingiberaceae which are endemic to the Philippines. Previously, Adelmeria had been considered a synonym of the genus Alpinia, however, after a study showed Alpina to be highly polyphyletic, it was determined in 2019 that Adelmeria was a distinct genus.'),
('Hornstedtia lophophora', 'The native range of this species is Philippines (Negros, Mindanao). It is a rhizomatous geophyte and grows primarily in the wet tropical biome. While its exact distribution is unclear, Hornstedtia lophophora is believed to originate from Southeast Asian regions. It likely thrives in humid environments typical of tropical rainforests.'),
('Alpinia musifolia', 'Native to the Philippines, this species inhabits low and medium elevation forests. Its growth habit and specific characteristics remain somewhat obscure due to limited documentation.'),
('Etlingera dostseiana', 'Unique among the Philippine Etlingera due to having an ovoid spike, papery bracts when fruiting, and stilt roots. It prefers warm, humid climates similar to other members of the Zingiberaceae family.'),
('Etlingera Pilosa', 'A Southeast Asian native, Etlingera pilosa appears to thrive in tropical environments. However, specific details about its habitat preferences and growth patterns are lacking. The native range of this species is Philippines (Negros). It is a rhizomatous geophyte and grows primarily in the wet tropical biome.'),
('Alpinia apoensis', 'The native range of this species is Philippines (Catanduanes, Mindanao). It is a rhizomatous geophyte and grows primarily in the wet tropical biome. It is an endemic Zingiberaceae species of uncertain identity that was first collected and described by Elmer over 90 years ago. This Philippine endemic species is known to inhabit mountainous regions. Its adaptations to high-altitude environments and unique characteristics remain areas for further study.');
''');
  }

  Future addGinger(
      {required String gingerName,
      required String gingerDescription,
      File? imageFile}) async {
    final db = await database;

    Uint8List? imageBytes;
    if (imageFile != null) {
      imageBytes = await imageFile.readAsBytes();
    }

    try {
      await db.insert("Gingers", {
        "ginger_id": null,
        "ginger_name": gingerDescription,
        "ginger_description": gingerName,
        "project_image": imageBytes,
      });
      // print("Localdata");
      return 'added';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future editGinger(
      {required String gingerName,
      required String gingerDescription,
      File? imageFile}) async {
    final db = await database;

    Uint8List? imageBytes;
    if (imageFile != null) {
      imageBytes = await imageFile.readAsBytes();
    }

    try {
      await db.update("Gingers", {
        "ginger_id": null,
        "ginger_name": gingerDescription,
        "ginger_description": gingerName,
        "project_image": imageBytes,
      });
      // print("Localdata");
      return 'Record Updated';
    } catch (e) {
      return 'Error: $e';
    }
  }

//function for adding projects
  Future addProject(
      {required String project_name,
      required String project_description,
      required String project_location,
      File? imageFile}) async {
    final db = await database;

    Uint8List? imageBytes;
    if (imageFile != null) {
      imageBytes = await imageFile.readAsBytes();
    }

    try {
      final DateTime now = DateTime.now();
      await db.insert("Projects", {
        "project_id": null,
        "project_name": project_name,
        "project_description": project_description,
        "project_location": project_location,
        "start_date": now.toString(),
        "project_image": imageBytes,
      });
      // print("Localdata");
      // return 'added';
      print('Project Added successfully!');
    } catch (e) {
      print('Error inserting quadrat: $e');

      // return 'Error: $e';
    }
  }

  static Future<Position> SampleGetCurrentLocation() async {
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
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
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

  Future addQuadrats(
      {required String quadrat_name,
      required String quadrat_description,
      required int projectID,
      File? imageFile}) async {
    final db = await database;

    Uint8List? imageBytes;
    if (imageFile != null) {
      imageBytes = await imageFile.readAsBytes();
    }
    Position? currentPosition;
    try {
      currentPosition = await getCurrentLocation();
      // if (currentPosition == null) {
      //   print('Failed to get current position');
      //   return;
      // }
    } catch (e) {
      print('Error getting current position: $e');
      return;
    }

    String lat = currentPosition.latitude.toString();
    String long = currentPosition.longitude.toString();

    try {
      await db.insert("Quadrats", {
        "quadrat_id": null,
        "quadrat_name": quadrat_name,
        "quadrat_description": quadrat_description,
        "latitude": lat,
        "longitude": long,
        "quadrat_image": imageBytes,
        // "elevation": currentPosition.elevation,
        "project_id": projectID
      });
      print('Quadrat inserted successfully!');
    } catch (e) {
      print('Error inserting quadrat: $e');
    }
  }

  Future<List<Map<String, Object?>>> readDataImages() async {
    final db = await database;
    return await db.query("image_meta_data");
  }

  Future<List<Map<String, Object?>>> readData() async {
    final db = await database;
    return await db.query("Projects");
  }

  Future<List<Map<String, Object?>>> readDataGinger() async {
    final db = await database;
    return await db.query("Gingers");
  }

  Future<List<Map<String, Object?>>> readSpeciesLibrary() async {
    final db = await database;
    return await db.query("Species");
  }

  Future<List<Map<String, dynamic>>> readDataQuadrat() async {
    final db = await database;

    try {
      print("Attempting to read quadrat data...");
      final List<Map<String, dynamic>> result = await db.query('Quadrats');

      print("Quadrats data retrieved: ${result.length} items");

      return result;
    } catch (e) {
      print('Error reading quadrat data: $e');
      return [];
    }
  }

  Future<List<Map<String, Object?>>> samplereadDataQuadrat() async {
    final db = await database;
    return await db.query("Quadrats");
  }
  // Future<List<Map<String, Object?>>> readDataQuadrat() async {
  //   try {
  //     final db = await database;
  //     final results = await db.query("Quadrats");
  //     print('Quadrats query results: $results');
  //     return results;
  //   } catch (e) {
  //     print('Error querying quadrats: $e');
  //     return [];
  //   }
  // }

  Future<MemoryImage?> getImageFromDb(int id) async {
    final db = await database;
    final result =
        await db.query("Projects", where: "project_id = ?", whereArgs: [id]);
    if (result.isNotEmpty && result.first["project_image"] != null) {
      Uint8List imageBytes = result.first["project_image"];
      return MemoryImage(imageBytes);

      // return Image.memory(imageBytes);
    }
    return null;
  }

//   Future<List<Map<String, Object?>>> getQuadratsByProjectID(
//       int projectID) async {
//     final db = await database;
//     // Query to get quadrats where the project_id matches the current project
//     return await db.query(
//       "Quadrats",
//       where: "project_id = ?",
//       whereArgs: [projectID],
//     );
//   }
//get all quadrats from project
  Future<List<Map<String, Object?>>> getQuadratsByProjectID(
      int projectID) async {
    try {
      final db = await database;
      // Query to get quadrats where the project_id matches the current project
      final results = await db.query(
        "Quadrats",
        where: "project_id = ?",
        whereArgs: [projectID],
      );
      // print('Quadrats query results: $results');
      return results;
    } catch (e) {
      print('Error querying quadrats: $e');
      return [];
    }
  }

  //get all gingers from quadrats
  Future<List<Map<String, Object?>>> getGingersFromQuadrats(
      int quadratID) async {
    try {
      final db = await database;
      // Query to get specified_quadrat_mapping where the quadrat_id matches the current quadrat
      final results = await db.query(
        "specied_quadrat_mapping",
        where: "quadrat_id = ?",
        whereArgs: [quadratID],
      );
      // print('Ginger query results: $results');
      return results;
    } catch (e) {
      print('Error querying ginger: $e');
      return [];
    }
  }

  Future deleteQuadrat({required int quadratid}) async {
    final db = await database;

    await db
        .delete('Quadrats', where: 'quadrat_id = ?', whereArgs: [quadratid]);
  }

  Future deleteProject({required int projectid}) async {
    final db = await database;

    await db
        .delete('Projects', where: 'project_id = ?', whereArgs: [projectid]);
  }

  Future addSpecies(
      {required String species_name,
      required String sub_family,
      required String species_description,
      required String tribe,
      File? imageFile}) async {
    final db = await database;

    Uint8List? imageBytes;
    if (imageFile != null) {
      imageBytes = await imageFile.readAsBytes();
    }

    try {
      await db.insert("Species", {
        "species_id": null,
        "species_name": species_name,
        "species_description": species_description,
        "sub_family": sub_family,
        "tribe": tribe,
        "species_image": imageBytes,
      });
      // print("Localdata");
      return 'added';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<List<Map<String, Object?>>> performSearch(String searchTerm) async {
    final db = await database;
    final results = await db.query("Projects",
        where: "project_name LIKE ? OR project_description LIKE ?",
        whereIn: ["%$searchTerm%", "%$searchTerm%"]);
    return results;
  }

  Future<List<String>> getImagesForQuadrat(int projectId) async {
    // Replace with your actual database query logic
    List<String> imagePaths = [];

    // Example query to fetch image paths for the given quadrat ID
    final db =
        await database; // Assuming you have a method to get the database instance
    // final List<Map<String, dynamic>> maps = await db.query(
    //   'images', // Replace with your actual images table name
    //   where: 'quadrat_id = ?', // Assuming you have a foreign key relationship
    //   whereArgs: [quadratId],
    // );
    final List<Map<String, dynamic>> maps = await db.query(
      'Quadrats', // Replace with your actual images table name
      where: 'project_id = ?', // Assuming you have a foreign key relationship
      whereArgs: [projectId],
    );
    // Extract image paths from the query result
    for (var map in maps) {
      imagePaths.add(map[
          'path']); // Replace 'path' with the actual column name for image paths
    }

    return imagePaths;
  }
}
