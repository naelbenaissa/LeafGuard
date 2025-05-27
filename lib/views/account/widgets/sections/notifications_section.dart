import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../services/notification_service.dart';
import '../../../widgets/notification_settings.dart';

class NotificationsSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const NotificationsSection({
    super.key,
    required this.isExpanded,
    required this.onTap,
  });

  Future<void> _showTestNotification(BuildContext context) async {
    var status = await Permission.notification.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      var result = await Permission.notification.request();

      if (!result.isGranted) {
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
                const NotificationSettings(),
                const SizedBox(height: 16),
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
