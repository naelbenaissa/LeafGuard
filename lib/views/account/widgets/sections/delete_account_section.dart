import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/user_service.dart';

class DeleteAccountSection extends StatelessWidget {
  const DeleteAccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();

    Future<void> deleteAccount() async {
      bool? confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Supprimer définitivement votre compte ?"),
            content: const Text("Cette action est irréversible. Toutes vos données seront définitivement supprimées."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Annuler"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        try {
          await userService.deleteAccount();
          if (context.mounted) {
            GoRouter.of(context).go('/auth');
          }
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur : $error")),
          );
        }
      }
    }

    return ListTile(
      leading: const Icon(Icons.delete, color: Colors.red),
      title: const Text("Supprimer mon compte"),
      onTap: deleteAccount,
    );
  }
}
