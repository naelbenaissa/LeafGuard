import 'package:supabase_flutter/supabase_flutter.dart';

class TasksService {
  final SupabaseClient supabase;

  // Injection du client Supabase pour accès aux opérations backend
  TasksService(this.supabase);

  /// Ajoute les tâches associées à une maladie pour l'utilisateur connecté.
  /// Récupère la maladie, ses tâches liées, puis insère les tâches personnalisées en fonction.
  Future<void> addTasksForDisease(String diseaseName) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception("Utilisateur non authentifié.");
    }
    final userId = user.id;

    final diseaseResponse = await supabase
        .from('diseases')
        .select('id')
        .eq('disease_name', diseaseName)
        .maybeSingle();

    if (diseaseResponse == null) {
      throw Exception("Maladie non trouvée dans la base.");
    }
    final diseaseId = diseaseResponse['id'];

    final taskLinks = await supabase
        .from('disease_tasks')
        .select('task_id')
        .eq('disease_id', diseaseId);

    if (taskLinks.isEmpty) {
      throw Exception("Aucune tâche associée à cette maladie.");
    }

    final taskIds = taskLinks.map((e) => e['task_id']).toList();

    // Récupération des tâches IA liées et insertion dans la table 'tasks' utilisateur
    final tasks = await supabase
        .from('ia_tasks')
        .select('*')
        .filter('id', 'in', taskIds);

    for (var task in tasks) {
      await supabase.from('tasks').insert({
        'user_id': userId,
        'title': task['title'],
        'description': task['description'],
        'due_date': DateTime.now().add(Duration(days: task['jours'])).toIso8601String(),
        'priority': task['priority'],
      });
    }
  }

  /// Récupère toutes les tâches d'un utilisateur triées par date d'échéance croissante.
  Future<List<Map<String, dynamic>>> fetchTasks(String? userId) async {
    if (userId == null) return [];

    final response = await supabase
        .from('tasks')
        .select('*')
        .eq('user_id', userId)
        .order('due_date', ascending: true);

    return response;
  }

  /// Ajoute une tâche personnalisée pour un utilisateur donné.
  /// Vérifie que l'insertion a bien eu lieu.
  Future<void> addTask(String userId, String title, String description, DateTime dueDate, String priority) async {
    final response = await Supabase.instance.client
        .from('tasks')
        .insert({
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'priority': priority,
    })
        .select();

    if (response.isEmpty) {
      throw Exception("Erreur: Aucune tâche insérée !");
    }
  }

  /// Met à jour une tâche existante via son ID.
  /// Lève une exception si une erreur survient.
  Future<void> updateTask(String taskId, String title, String description, DateTime dueDate, String priority) async {
    final response = await supabase.from('tasks').update({
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'priority': priority,
    }).match({'id': taskId});

    if (response.error != null) {
      throw Exception('Erreur lors de la modification de la tâche: ${response.error!.message}');
    }
  }

  /// Récupère les tâches liées à une maladie spécifique en se basant sur la table relationnelle.
  Future<List<Map<String, dynamic>>> getTasksForDisease(String diseaseName) async {
    final diseaseResponse = await supabase
        .from('diseases')
        .select('id')
        .eq('disease_name', diseaseName)
        .maybeSingle();

    if (diseaseResponse == null) {
      return [];
    }
    final diseaseId = diseaseResponse['id'];

    final taskLinks = await supabase
        .from('disease_tasks')
        .select('task_id')
        .eq('disease_id', diseaseId);

    if (taskLinks.isEmpty) {
      return [];
    }

    final taskIds = taskLinks.map((e) => e['task_id']).toList();

    final tasks = await supabase
        .from('ia_tasks')
        .select('*')
        .filter('id', 'in', taskIds.cast<dynamic>());

    return List<Map<String, dynamic>>.from(tasks);
  }

  /// Supprime une tâche par son ID.
  /// Gestion des erreurs incluse.
  Future<void> deleteTask(String taskId) async {
    try {
      await supabase.from('tasks').delete().match({'id': taskId});
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la tâche: $e');
    }
  }
}
