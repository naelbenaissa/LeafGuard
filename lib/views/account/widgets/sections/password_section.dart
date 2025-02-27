import 'package:flutter/material.dart';
import '../../../../services/user_service.dart';

class ChangePasswordSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const ChangePasswordSection({super.key, required this.isExpanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    Future<void> _changePassword() async {
      if (newPasswordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Les nouveaux mots de passe ne correspondent pas.")),
        );
        return;
      }

      try {
        await userService.changePassword(newPasswordController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mot de passe mis à jour avec succès !")),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $error")),
        );
      }
    }

    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.lock, color: isExpanded ? Colors.green : Colors.black),
          title: const Text("Changer le mot de passe"),
          onTap: onTap,
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                TextField(controller: newPasswordController, obscureText: true, decoration: const InputDecoration(labelText: "Nouveau mot de passe")),
                TextField(controller: confirmPasswordController, obscureText: true, decoration: const InputDecoration(labelText: "Confirmer le mot de passe")),
                ElevatedButton(onPressed: _changePassword, child: const Text("Modifier")),
              ],
            ),
          ),
      ],
    );
  }
}
