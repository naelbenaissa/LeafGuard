import 'package:supabase_flutter/supabase_flutter.dart';

class TasksService {
  final SupabaseClient supabase;

  TasksService(this.supabase);

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
      throw Exception("❌ Erreur: Aucune tâche insérée !");
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
