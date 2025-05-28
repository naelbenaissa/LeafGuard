import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/user_service.dart';

/// Section de l'interface dédiée à la suppression du compte utilisateur.
class DeleteAccountSection extends StatelessWidget {
  const DeleteAccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();

    /// Affiche une boîte de dialogue de confirmation, puis supprime le compte si l'utilisateur confirme.
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
          await userService.deleteAccount(); // Suppression via le service utilisateur
          if (context.mounted) {
            GoRouter.of(context).go('/auth'); // Redirection vers la page d’authentification après suppression
          }
        } catch (error) {
          // Affiche un message d'erreur en cas d'échec
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur : $error")),
          );
        }
      }
    }

    // Élément de menu affichant l'option de suppression
    return ListTile(
      leading: const Icon(Icons.delete, color: Colors.red),
      title: const Text("Supprimer mon compte"),
      onTap: deleteAccount,
    );
  }
}
