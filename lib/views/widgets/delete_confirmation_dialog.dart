import 'package:flutter/material.dart';

/// Affiche une boîte de dialogue de confirmation de suppression
/// Retourne un booléen indiquant si l'utilisateur confirme la suppression (true) ou annule (false).
Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text("Supprimer ce scan ?"), // Titre de la boîte de dialogue
        content: const Text("Cette action est irréversible."), // Message d'alerte
        actions: [
          TextButton(
            // Annule la suppression et ferme la boîte en retournant false
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            // Confirme la suppression et ferme la boîte en retournant true
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              "Supprimer",
              style: TextStyle(color: Colors.red), // Bouton en rouge pour insister sur l'action destructive
            ),
          ),
        ],
      );
    },
  ) ?? false; // En cas de fermeture sans choix (ex: back button), retourne false par défaut
}
