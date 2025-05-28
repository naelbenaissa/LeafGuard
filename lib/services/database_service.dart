import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  // Singleton instance
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  // Private constructor pour singleton
  DatabaseService._internal();

  // Factory pour retourner l'instance unique
  factory DatabaseService() {
    return _instance;
  }

  // Getter pour accéder à la base de données, initialisation lazy
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialisation de la base SQLite locale avec création des tables
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

  // Création des tables nécessaires au projet
  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE diseases (
        id INTEGER PRIMARY KEY,
        plant_name TEXT NOT NULL,
        disease_name TEXT NOT NULL UNIQUE,
        is_healthy BOOLEAN NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY,
        task_description TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE disease_tasks (
        id INTEGER PRIMARY KEY,
        disease_id INTEGER NOT NULL,
        task_id INTEGER NOT NULL,
        FOREIGN KEY (disease_id) REFERENCES diseases(id) ON DELETE CASCADE,
        FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
      );
    ''');
  }

  /// Synchronisation des données depuis Supabase vers la base locale SQLite.
  /// Supprime les anciennes données avant insertion pour éviter les doublons.
  Future<void> syncFromSupabase() async {
    final db = await database;
    final supabase = Supabase.instance.client;

    // Récupérer toutes les maladies depuis Supabase et mettre à jour SQLite
    final diseases = await supabase.from('diseases').select();
    await db.transaction((txn) async {
      await txn.delete('diseases');
      for (var disease in diseases) {
        await txn.insert('diseases', disease, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });

    // Récupérer toutes les tâches depuis Supabase et mettre à jour SQLite
    final tasks = await supabase.from('tasks').select();
    await db.transaction((txn) async {
      await txn.delete('tasks');
      for (var task in tasks) {
        await txn.insert('tasks', task, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });

    // Récupérer les relations maladie ↔ tâche et mettre à jour SQLite
    final diseaseTasks = await supabase.from('disease_tasks').select();
    await db.transaction((txn) async {
      await txn.delete('disease_tasks');
      for (var dt in diseaseTasks) {
        await txn.insert('disease_tasks', dt, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  /// Récupère la liste des tâches associées à une maladie identifiée par son nom.
  /// Utilise une requête SQL avec jointures pour assurer l'intégrité des données.
  Future<List<Map<String, dynamic>>> getTasksForDisease(String diseaseName) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT tasks.* FROM tasks
      JOIN disease_tasks ON tasks.id = disease_tasks.task_id
      JOIN diseases ON disease_tasks.disease_id = diseases.id
      WHERE diseases.disease_name = ?
    ''', [diseaseName]);
  }

  /// Ferme proprement la connexion à la base de données SQLite
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
