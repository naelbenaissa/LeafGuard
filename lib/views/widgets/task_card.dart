import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/services/tasks_service.dart';
import '../../services/notification_service.dart';

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
    return Card(
      elevation: 4, // Ombre portée autour de la carte
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Coins arrondis
      ),
      child: ListTile(
        leading: Icon(
          Icons.flag,
          // Couleur de l'icône selon la priorité
          color: priority == 'high'
              ? Colors.red
              : priority == 'medium'
              ? Colors.orange
              : Colors.green,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () async {
            // Demander confirmation avant suppression
            final confirmed = await _showDeleteConfirmationDialog(context);
            if (confirmed == true) {
              await _deleteTask(context); // Supprimer si confirmé
            }
          },
        ),
      ),
    );
  }

  /// Supprime la tâche de la base et annule la notification associée
  Future<void> _deleteTask(BuildContext context) async {
    try {
      final taskService = TasksService(Supabase.instance.client);

      // 1. Supprimer la tâche dans la base de données
      await taskService.deleteTask(id);

      // 2. Annuler la notification liée (identifiée par hashCode de l'id)
      await NotificationService().cancelNotification(id.hashCode);

      // 3. Rafraîchir la liste des tâches après un court délai (animation terminée)
      Future.delayed(const Duration(milliseconds: 300), () {
        if (context.mounted) {
          refreshTasks(); // Callback pour recharger la liste

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tâche supprimée")),
          );
        }
      });
    } catch (e) {
      // Afficher une erreur en cas d'exception
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      }
    }
  }

  /// Affiche une boîte de dialogue demandant la confirmation de suppression
  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer la tâche ?"),
        content: const Text("Voulez-vous vraiment supprimer cette tâche ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Annuler
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirmer
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }
}
