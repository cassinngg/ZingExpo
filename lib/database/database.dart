import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition();
}

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
  ginger_image TEXT,
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
  length TEXT,
  width TEXT,
  latitude TEXT,
  quadrat_size TEXT,
  quadrat_image BLOB,
  project_id INTEGER,
  FOREIGN KEY (project_id) REFERENCES Projects(project_id)
  );
  ''');
    await db.execute('''
  CREATE TABLE image_meta_data(
  img_data INTEGER PRIMARY KEY AUTOINCREMENT,
  image_name TEXT NOT NULL,
  additional_details TEXT,
  image_path BLOB,
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

    await db.execute(
        '''INSERT INTO Gingers (ginger_name, ginger_description, ginger_image)
VALUES 
('Alpinia Haenkei', 'Alpinia is a genus of flowering plants in the ginger family, Zingiberaceae. Species are native to Asia, Australia, and the Pacific Islands, where they occur in tropical and subtropical climates. This Philippine endemic species grows in low and medium elevation forests, typically reaching heights of 1-3 meters. Its pseudostems are composed of overlapping leaf sheaths, forming a distinctive architectural feature.', 'assets/species_image/Alpinia_haenkei.jpg'),
('Adelmeria Alpina', 'As an endemic species to the Philippines, Adelmeria alpina is relatively understudied. Limited information suggests it may inhabit tropical forests, but further research is needed to confirm its ecological characteristics. Adelmeria is a genus of perennial herbs in the family Zingiberaceae which are endemic to the Philippines. Previously, Adelmeria had been considered a synonym of the genus Alpinia, however, after a study showed Alpina to be highly polyphyletic, it was determined in 2019 that Adelmeria was a distinct genus.', 'assets/species_image/Adelmeria_alpina.jpg'),
('Hornstedtia lophophora', 'The native range of this species is Philippines (Negros, Mindanao). It is a rhizomatous geophyte and grows primarily in the wet tropical biome. While its exact distribution is unclear, Hornstedtia lophophora is believed to originate from Southeast Asian regions. It likely thrives in humid environments typical of tropical rainforests.', 'assets/species_image/Hornstedtia_lophophora.jpg'),
('Alpinia musifolia', 'Native to the Philippines, this species inhabits low and medium elevation forests. Its growth habit and specific characteristics remain somewhat obscure due to limited documentation.', 'assets/species_image/Alpinia_musifolia.jpg'),
('Etlingera dostseiana', 'Unique among the Philippine Etlingera due to having an ovoid spike, papery bracts when fruiting, and stilt roots. It prefers warm, humid climates similar to other members of the Zingiberaceae family.', 'assets/species_image/Etlingera-dostseiana.jpg'),
('Etlingera Pilosa', 'A Southeast Asian native, Etlingera pilosa appears to thrive in tropical environments. However, specific details about its habitat preferences and growth patterns are lacking. The native range of this species is Philippines (Negros). It is a rhizomatous geophyte and grows primarily in the wet tropical biome.', 'assets/species_image/Etlingera _pilosa.jpg'),
('Alpinia apoensis', 'The native range of this species is Philippines (Catanduanes, Mindanao). It is a rhizomatous geophyte and grows primarily in the wet tropical biome. It is an endemic Zingiberaceae species of uncertain identity that was first collected and described by Elmer over 90 years ago. This Philippine endemic species is known to inhabit mountainous regions. Its adaptations to high-altitude environments and unique characteristics remain areas for further study.', 'assets/species_image/Alpinia_apoensis.jpg');
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
      {required String projectName,
      required String projectDescription,
      required String projectLocation,
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
        "project_name": projectName,
        "project_description": projectDescription,
        "project_location": projectLocation,
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
      {required String quadratName,
      required String quadratDescription,
      required String length,
      required String width,
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
        "quadrat_name": quadratName,
        "quadrat_size": quadratDescription,
        "length": length,
        "width": width,
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

  Future<List<Map<String, dynamic>>> fetchGingers() async {
    final db = await database;
    return await db.qury("Gingers");
  }

  Future<List<Map<String, Object?>>> readDataImages() async {
    final db = await database;
    return await db.query("image_meta_data");
  }

  Future<int> insertImageData(Map<String, dynamic> imageData) async {
    final db = await database;
    return await db.insert('image_meta_data', imageData);
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
//     return await db.query(
//       "Quadrats",
//       where: "project_id = ?",
//       whereArgs: [projectID],
//     );
//   }
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

  Future<int> getGroupedSpeciesCount() async {
    final db = await database; // Get the database instance
    final List<Map<String, dynamic>> groupedSpecies = await db.rawQuery(
      '''
    SELECT COUNT(DISTINCT image_name) as unique_species_count
    FROM image_meta_data
    ''',
    );

    // Return the count of unique species
    return groupedSpecies.isNotEmpty
        ? groupedSpecies.first['unique_species_count'] as int
        : 0;
  }

  Future<List<Map<String, Object?>>> getProjects(int projectID) async {
    try {
      final db = await database;
      // Query to get quadrats where the project_id matches the current project
      final results = await db.query(
        "Projects",
        where: "project_id = ?",
        whereArgs: [projectID],
      );
      // print('Quadrats query results: $results');
      return results;
    } catch (e) {
      print('Error querying projects: $e');
      return [];
    }
  }

  Future<void> updateQuadrat({
    required int quadratID,
    required String quadratName,
    required String length,
    required String width,
    File? imageFile,
  }) async {
    final db = await database;

    Uint8List? imageBytes;
    if (imageFile != null) {
      imageBytes = await imageFile.readAsBytes();
    }

    try {
      await db.update(
        "Quadrats",
        {
          "quadrat_name": quadratName,
          "length": length,
          "width": width,
          "quadrat_image": imageBytes,
        },
        where: "quadrat_id = ?",
        whereArgs: [quadratID],
      );
      print('Quadrat updated successfully!');
    } catch (e) {
      print('Error updating quadrat: $e');
    }
  }

  Future<List<Map<String, Object?>>> getIdentifiedSpeciesByQuadrat(
      int projectId) async {
    try {
      final db = await database;
      // Query to get quadrats where the project_id matches the current project
      final results = await db.query("image_meta_data",
          where: "project_id = ?", whereArgs: [projectId]);
      // print('Quadrats query results: $results');
      return results;
    } catch (e) {
      print('Error querying Species: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getImagesByProject(int projectId) async {
    final db = await database;
    final List<Map<String, dynamic>> total = await db.rawQuery(
      '''
    SELECT image_name, image_path, COUNT(*) as total_count
    FROM image_meta_data
    WHERE project_id = ?
    GROUP BY image_name
    ''',
      [projectId],
    );
    return total;
  }

  // Future<List<Map<String, dynamic>>> getImagesByProject(int projectId) async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> total = await db.rawQuery(
  //     '''
  //   SELECT image_name, COUNT(*) as total_count
  //   FROM image_meta_data
  //   WHERE project_id = ?
  //   GROUP BY image_name
  //   ''',
  //     [projectId],
  //   );
  //   return total;
  // }
  Future<List<Map<String, dynamic>>> getGroupedSpecies() async {
    final db = await database; // Get the database instance
    final List<Map<String, dynamic>> groupedSpecies = await db.rawQuery(
      '''
      SELECT image_name, COUNT(*) as total_count
      FROM image_meta_data
      GROUP BY image_name
      ''',
    );
    return groupedSpecies; // Return the list of grouped species and their counts
  }

//  Future<List<Map<String, Object?>>> getIdentifiedSpeciesByQuadrat(
//       int quadratID, int projectId) async {
//     try {
//       final db = await database;
//       // Query to get quadrats where the project_id matches the current project
//       final results = await db.query("image_meta_data",
//           where: "project_id = ? AND quadrat_id = ?",
//           whereArgs: [projectId, quadratID]);
//       // print('Quadrats query results: $results');
//       return results;
//     } catch (e) {
//       print('Error querying quadrats: $e');
//       return [];
//     }
//   }
  //get all gingers from quadrats
  Future<List<Map<String, Object?>>> getGingersFromQuadrats(
      int quadratID) async {
    try {
      final db = await database;
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

  Future<List<Map<String, Object?>>> getIdentifiedSpeciesByProjectAndQuadrat(
      int quadratId) async {
    try {
      final db = await database;
      final results = await db.query(
        "image_meta_data",
        where: "quadrat_id = ?",
        whereArgs: [quadratId],
      );
      return results;
    } catch (e) {
      print('Error querying identified species: $e');
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

  Future<void> saveIdentifiedSpecie({
    required String speciesName,
    required String additionalDetails,
    required String? imagePath,
    required double latitude,
    required double longitude,
    required int projectID,
    required int quadratID,
  }) async {
    final db = await database;

    try {
      await db.insert("idetified_species", {
        "species_collected_id": null,
        "species_id": null,
      });

      // Save the image metadata in the image_meta_data table
      await db.insert("image_meta_data", {
        "image_name": speciesName,
        "additional_details": additionalDetails,
        "image_path": imagePath,
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
        "elevation": null, // Add if you have elevation data
        "project_id": projectID, // Add if you have a project ID
        "quadrat_id": quadratID, // Add if you have a quadrat ID
        "capture_date": DateTime.now().toIso8601String(), // Capture date
      });

      print('Identified species saved successfully!');
    } catch (e) {
      print('Error saving identified species: $e');
    }
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

  Future<void> updateProject({
    required int projectID,
    required String projectName,
    required String projectDescription,
    required String projectLocation,
    File? imageFile,
  }) async {
    final db = await database;

    Uint8List? imageBytes;
    if (imageFile != null) {
      imageBytes = await imageFile.readAsBytes();
    }

    try {
      await db.update(
        "Projects",
        {
          "project_name": projectName,
          "project_description": projectDescription,
          "project_location": projectLocation,
          "project_image": imageBytes,
        },
        where: "project_id = ?",
        whereArgs: [projectID],
      );
      print('Project updated successfully!');
    } catch (e) {
      print('Error updating project: $e');
    }
  }

  // Future<List<Map<String, dynamic>>> fetchQuadratsByProjectID(
  //     int projectID) async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> quadrats = await db.query(
  //     'Quadrats',
  //     where: 'project_id = ?',
  //     whereArgs: [projectID],
  //   );
  //   return quadrats;
  //   // return List.generate(maps.length, (i) {
  //   //   return maps[i]['quadrat_name'] as String;
  //   // });
  // }

  Future<List<Map<String, dynamic>>> fetchQuadratsByProjectId(
      int projectId) async {
    final db = await database;
    return await db.query(
      'Quadrats',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
  }

  // Future<String?> getProjectNameByID(int projectID) async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> results = await db.query(
  //     'Projects',
  //     where: 'project_id = ?',
  //     whereArgs: [projectID],
  //   );

  //   if (results.isNotEmpty) {
  //     return results.first['project_name'] as String;
  //   }
  //   return null;
  // }
Future<String?> getProjectNameById(int projectId) async {
    final db = await database;

    // Query to get the project name by ID
    List<Map<String, dynamic>> result = await db.query(
      'Projects',
      columns: ['project_name'],
      where: 'project_id = ?',
      whereArgs: [projectId],
    );

    // Check if we have results and return the project name
    if (result.isNotEmpty) {
      return result.first['project_name'] as String?;
    }
    
    return null; // Return null if no project found
  }

  Future<String?> getQuadratNameByID(int quadratID) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'Quadrats',
      where: 'quadrat_id = ?',
      whereArgs: [quadratID],
    );

    if (results.isNotEmpty) {
      return results.first['quadrat_name'] as String;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> fetchProjectsWithIds() async {
    final db = await database;
    return await db.query('Projects', columns: ['project_id', 'project_name']);
  }

  Future<List<Map<String, dynamic>>> fetchQuadratsWithIds() async {
    final db = await database;
    return await db.query('Quadrats', columns: ['quadrat_id', 'quadrat_name']);
  }

  Future<List<String>> fetchProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Projects');

    return List.generate(maps.length, (i) {
      return maps[i]['project_name'] as String;
    });
  }

  Future<List<String>> fetchQuadrats() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Quadrats');

    return List.generate(maps.length, (i) {
      return maps[i]['quadrat_name'] as String;
    });
  }

  Future<List<String>> getImagesForQuadrat(int projectId) async {
    List<String> imagePaths = [];

    final db = await database;
    // final List<Map<String, dynamic>> maps = await db.query(
    //   'images', /
    //   where: 'quadrat_id = ?',
    //   whereArgs: [quadratId],
    // );
    final List<Map<String, dynamic>> maps = await db.query(
      'Quadrats',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
    for (var map in maps) {
      imagePaths.add(map['path']);
    }

    return imagePaths;
  }
}
