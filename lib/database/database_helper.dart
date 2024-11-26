import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'image_database.db');
    return await openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE IF NOT EXISTS image_meta_data(
          img_data INTEGER PRIMARY KEY AUTOINCREMENT,
          image_name TEXT NOT NULL,
          image_path TEXT,
          latitude TEXT,
          longitude TEXT,
          elevation TEXT,
          capture_date TEXT
        );
        ''');
      },
      version: 1,
    );
  }

  // Future<int> insertImageData(Map<String, dynamic> imageData) async {
  //   final db = await database;
  //   return await db.insert('image_meta_data', imageData);
  // }

  Future<List<Map<String, dynamic>>> getAllImages() async {
    final db = await database;
    return await db.query('image_meta_data');
  }
}
