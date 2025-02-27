import 'package:flutter/material.dart';

import '../../../widgets/notification_settings.dart';

class NotificationsSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const NotificationsSection({super.key, required this.isExpanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.notifications, color: isExpanded ? Colors.green : Colors.black),
          title: const Text("Gérer les notifications"),
          onTap: onTap,
        ),
        if (isExpanded)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: NotificationSettings(),
          ),
      ],
    );
  }
}
