import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../services/notification_service.dart';
import '../../../widgets/notification_settings.dart';

/// Section permettant de gérer les paramètres de notifications utilisateur.
class NotificationsSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const NotificationsSection({
    super.key,
    required this.isExpanded,
    required this.onTap,
  });

  /// Affiche une notification de test après vérification et demande des permissions.
  Future<void> _showTestNotification(BuildContext context) async {
    var status = await Permission.notification.status;

    // Demande de permission si nécessaire
    if (status.isDenied || status.isPermanentlyDenied) {
      var result = await Permission.notification.request();

      if (!result.isGranted) {
        // Feedback utilisateur en cas de refus
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "La permission de notification est nécessaire pour recevoir des alertes.",
              ),
            ),
          );
        }
        return;
      }
    }

    // Planifie une notification de test après 3 secondes
    final scheduledDate = DateTime.now().add(const Duration(seconds: 3));
    NotificationService().scheduleNotificationForTask(
      id: 0,
      title: 'Test Notification',
      body: 'Cette notification est déclenchée après 3 secondes.',
      date: scheduledDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Titre de la section avec expansion
        ListTile(
          leading: Icon(
            Icons.notifications,
            color: isExpanded
                ? Colors.green
                : Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          title: const Text("Gérer les notifications"),
          onTap: onTap,
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const NotificationSettings(), // Composant des paramètres personnalisés
                const SizedBox(height: 16),
                // Bouton pour déclencher la notification de test
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ElevatedButton(
                    onPressed: () => _showTestNotification(context),
                    child: const Text("Tester l'envoi de notification"),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
