import 'package:flutter/material.dart';
import 'package:ui_leafguard/views/widgets/notification_settings.dart';

void showNotificationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Choisissez le niveau de notifications"),
        content: const NotificationSettings(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      );
    },
  );
}
