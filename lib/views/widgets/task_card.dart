import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/services/tasks_service.dart';

class TaskCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String priority;
  final VoidCallback refreshTasks;

  const TaskCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.refreshTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmationDialog(context);
      },
      onDismissed: (direction) async {
        await _deleteTask(context);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: const Icon(Icons.task, color: Colors.green),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(description),
          trailing: Icon(
            Icons.flag,
            color: priority == 'high'
                ? Colors.red
                : priority == 'medium'
                    ? Colors.orange
                    : Colors.green,
          ),
        ),
      ),
    );
  }

  /// Supprime la tâche via TasksService
  Future<void> _deleteTask(BuildContext context) async {
    try {
      final taskService = TasksService(Supabase.instance.client);
      await taskService.deleteTask(id);

      // IMPORTANT : Ne pas appeler refreshTasks tout de suite !
      // Laisse le Dismissible terminer son animation avant de rebuild.
      Future.delayed(const Duration(milliseconds: 300), () {
        if (context.mounted) {
          refreshTasks();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tâche supprimée")),
          );
        }
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      }
    }
  }


  /// Confirmation avant suppression
  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer la tâche ?"),
        content: const Text("Voulez-vous vraiment supprimer cette tâche ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }
}
