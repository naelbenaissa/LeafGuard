import 'package:supabase_flutter/supabase_flutter.dart';

class TasksService {
  final SupabaseClient supabase;

  TasksService(this.supabase);

  Future<void> addTask(String userId, String title, String description, DateTime dueDate, String priority) async {
    final response = await supabase.from('tasks').insert({
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'priority': priority,
      'created_at': DateTime.now().toIso8601String(),
    });

    if (response.error != null) {
      throw Exception('Erreur lors de l\'ajout de la tâche: ${response.error!.message}');
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
