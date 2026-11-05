// lib/data/database_helper.dart
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';
import '../models/mood_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('moodwave.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mood_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp INTEGER NOT NULL,
        mood INTEGER NOT NULL,
        energy INTEGER NOT NULL,
        note TEXT NOT NULL,
        activities TEXT NOT NULL
      )
    ''');
  }

  Future<List<MoodEntry>> getAllEntries() async {
    final db = await instance.database;
    final result = await db.query('mood_entries', orderBy: 'timestamp DESC');
    return result.map((json) => MoodEntry.fromMap(json)).toList();
  }

  Future<int> insert(MoodEntry entry) async {
    final db = await instance.database;
    return await db.insert('mood_entries', entry.toMap());
  }

  Future<int> update(MoodEntry entry) async {
    final db = await instance.database;
    return await db.update(
      'mood_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'mood_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Generador de 90 Días Sintéticos (Etapa 2 - Pruebas de Núcleo)
  Future<void> seed90DaysSyntheticData() async {
    final db = await instance.database;
    await db.delete('mood_entries');

    final batch = db.batch();
    final random = Random(42);
    final now = DateTime.now();

    for (int day = 89; day >= 0; day--) {
      final date = now.subtract(Duration(days: day));
      final ts = date.millisecondsSinceEpoch;

      final hasExercise = random.nextDouble() > 0.4;
      final hasWork = random.nextDouble() > 0.3;

      final acts = <String>[];
      if (hasExercise) acts.add("Ejercicio");
      if (hasWork) acts.add("Trabajo");
      if (random.nextDouble() > 0.5) acts.add("Lectura");

      int baseMood = 5;
      int baseEnergy = 5;

      if (hasExercise) { baseMood += 2; baseEnergy += 1; }
      if (hasWork) { baseEnergy -= 2; }

      final mood = (baseMood + (random.nextInt(3) - 1)).clamp(1, 8);
      final energy = (baseEnergy + (random.nextInt(3) - 1)).clamp(1, 10);

      batch.insert('mood_entries', {
        'timestamp': ts,
        'mood': mood,
        'energy': energy,
        'note': hasExercise ? 'Buen entrenamiento' : 'Día regular',
        'activities': acts.join('|'),
      });
    }

    await batch.commit();
  }
}