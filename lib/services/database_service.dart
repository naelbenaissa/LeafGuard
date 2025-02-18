import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'leafguard.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE diseases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plant_name TEXT NOT NULL,
        disease_name TEXT NOT NULL UNIQUE,
        is_healthy BOOLEAN NOT NULL DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_description TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE disease_tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        disease_id INTEGER NOT NULL,
        task_id INTEGER NOT NULL,
        FOREIGN KEY (disease_id) REFERENCES diseases(id) ON DELETE CASCADE,
        FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
      );
    ''');

    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    List<Map<String, dynamic>> diseases = [
      {'plant_name': 'Poivron', 'disease_name': 'Poivron - Dépérissement bactérien', 'is_healthy': 0},
      {'plant_name': 'Poivron', 'disease_name': 'Poivron - Sain', 'is_healthy': 1},
      {'plant_name': 'Pomme de terre', 'disease_name': 'Pomme de terre - Brûlure précoce', 'is_healthy': 0},
      {'plant_name': 'Pomme de terre', 'disease_name': 'Pomme de terre - Brûlure tardive', 'is_healthy': 0},
      {'plant_name': 'Pomme de terre', 'disease_name': 'Pomme de terre - Saine', 'is_healthy': 1},
      {'plant_name': 'Tomate', 'disease_name': 'Tomate - Tache bactérienne', 'is_healthy': 0},
      {'plant_name': 'Tomate', 'disease_name': 'Tomate - Saine', 'is_healthy': 1},
    ];

    for (var disease in diseases) {
      await db.insert('diseases', disease);
    }

    // Insertion des tâches avec récupération de leur ID
    List<int> taskIds = [];
    List<String> taskDescriptions = [
      'Éliminer les feuilles infectées',
      'Appliquer un traitement au cuivre',
      'Surveiller l\'évolution',
      'Retirer les parties infectées',
      'Appliquer un fongicide naturel',
      'Espacer les plants pour l\'aération'
    ];

    for (var task in taskDescriptions) {
      int taskId = await db.insert('tasks', {'task_description': task});
      taskIds.add(taskId);
    }

    // Association des maladies aux tâches
    Map<String, List<int>> diseaseTaskMapping = {
      'Poivron - Dépérissement bactérien': [taskIds[0], taskIds[1], taskIds[2]],
      'Pomme de terre - Brûlure précoce': [taskIds[3], taskIds[4], taskIds[5]],
      'Tomate - Tache bactérienne': [taskIds[0], taskIds[1], taskIds[5]],
    };

    for (var entry in diseaseTaskMapping.entries) {
      String diseaseName = entry.key;
      List<int> tasks = entry.value;

      final diseaseQuery = await db.query(
        'diseases',
        columns: ['id'],
        where: 'disease_name = ?',
        whereArgs: [diseaseName],
      );

      if (diseaseQuery.isNotEmpty) {
        int diseaseId = diseaseQuery.first['id'] as int;
        for (var taskId in tasks) {
          await db.insert('disease_tasks', {'disease_id': diseaseId, 'task_id': taskId});
        }
      }
    }
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}