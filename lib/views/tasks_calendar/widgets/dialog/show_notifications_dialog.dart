import 'package:flutter/material.dart';
import 'package:ui_leafguard/views/widgets/notification_settings.dart'; // Import du widget personnalisé pour gérer les réglages des notifications

/// Fonction pour afficher une boîte de dialogue permettant de choisir le niveau de notifications
void showNotificationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        // Titre de la boîte de dialogue
        title: const Text("Choisissez le niveau de notifications"),
        // Contenu : widget custom qui affiche les options de notifications
        content: const NotificationSettings(),
        // Actions sous la boîte de dialogue (boutons)
        actions: [
          TextButton(
            // Bouton pour fermer la boîte de dialogue
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      );
    },
  );
}
