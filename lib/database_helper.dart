// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'dart:async';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;
//   DatabaseHelper._internal();

//   static Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB();
//     return _database!;
//   }

//   Future<Database> _initDB() async {
//     String path = join(await getDatabasesPath(), 'activation_codes.db');
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE codes (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             code TEXT UNIQUE NOT NULL
//           )
//         ''');
//         await db.insert('codes', {'code': '123456'}); // Default code
//       },
//     );
//   }

//   Future<bool> checkCodeExists(String code) async {
//     final db = await database;
//     List<Map<String, dynamic>> result = await db.query('codes', where: 'code = ?', whereArgs: [code]);
//     return result.isNotEmpty;
//   }

//   Future<bool> insertCode(String code) async {
//     final db = await database;
//     try {
//       await db.insert('codes', {'code': code});
//       return true;
//     } catch (e) {
//       return false; // Code already exists
//     }
//   }
// }

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
    String path = join(await getDatabasesPath(), "kiosk_database.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE activation_codes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT UNIQUE,
        cycle TEXT,
        activationDate TEXT
      )
    ''');
  }

  Future<bool> insertCode(String code, {String cycle = "monthly"}) async {
    final db = await database;
    try {
      await db.insert(
        'activation_codes',
        {
          'code': code,
          'cycle': cycle,
          'activationDate': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      return true;
    } catch (e) {
      return false; // Code already exists
    }
  }

  Future<bool> checkCodeExists(String code) async {
    final db = await database;
    var result = await db.query(
      'activation_codes',
      where: 'code = ?',
      whereArgs: [code],
    );
    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getActivationDetails(String code) async {
    final db = await database;
    var result = await db.query(
      'activation_codes',
      where: 'code = ?',
      whereArgs: [code],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> updateCycle(String code, String newCycle) async {
    final db = await database;
    await db.update(
      'activation_codes',
      {'cycle': newCycle},
      where: 'code = ?',
      whereArgs: [code],
    );
  }

  Future<void> updateActivationDate(String code) async {
    final db = await database;
    await db.update(
      'activation_codes',
      {
        'activationDate': DateTime.now().toIso8601String(),
      },
      where: 'code = ?',
      whereArgs: [code],
    );
  }

  Future<void> deleteCode(String code) async {
    final db = await database;
    await db.delete(
      'activation_codes',
      where: 'code = ?',
      whereArgs: [code],
    );
  }
}
