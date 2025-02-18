import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'nagme.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sleep_data(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bedtime TEXT,
        wakeup_time TEXT,
        desired_bedtime TEXT,
        desired_wakeup_time TEXT,
        nap_during_day INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE water_intake(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        glasses INTEGER,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE smoking_data(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cigarettes INTEGER,
        date TEXT
      )
    ''');
  }

  Future<void> insertSleepData(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('sleep_data', data);
  }

  Future<void> insertWaterIntake(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('water_intake', data);
  }

  Future<void> insertSmokingData(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('smoking_data', data);
  }

  Future<List<Map<String, dynamic>>> getSleepData() async {
    final db = await database;
    return await db.query('sleep_data');
  }

  Future<List<Map<String, dynamic>>> getWaterIntake() async {
    final db = await database;
    return await db.query('water_intake');
  }

  Future<List<Map<String, dynamic>>> getSmokingData() async {
    final db = await database;
    return await db.query('smoking_data');
  }
}