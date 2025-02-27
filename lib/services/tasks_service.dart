import 'package:supabase_flutter/supabase_flutter.dart';

class TasksService {
  final SupabaseClient supabase;

  TasksService(this.supabase);

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

  Future<List<Map<String, dynamic>>> fetchTasks(String? userId) async {
    if (userId == null) return [];

    final response = await supabase
        .from('tasks')
        .select('*')
        .eq('user_id', userId)
        .order('due_date', ascending: true);

    return response;
  }

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

    if (response == null || response.isEmpty) {
      throw Exception("Erreur: Aucune tâche insérée !");
    }
  }


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

  Future<void> deleteTask(String taskId) async {
    final response = await supabase.from('tasks').delete().match({'id': taskId});

    if (response.error != null) {
      throw Exception('Erreur lors de la suppression de la tâche: ${response.error!.message}');
    }
  }
}
