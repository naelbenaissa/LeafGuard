import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/user_service.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  String? _selectedNotification;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _fetchNotificationSetting();
  }

  /// Récupérer les préférences de notification via `UserService`
  Future<void> _fetchNotificationSetting() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final userData = await _userService.fetchUserData(userId);
    if (userData != null && userData['notifications'] != null) {
      setState(() {
        _selectedNotification = userData['notifications'];
      });
    }
  }

  /// Mettre à jour la valeur des notifications via `UserService`
  Future<void> _updateNotificationSetting(String value) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      setState(() {
        _selectedNotification = value;
      });

      await Supabase.instance.client
          .from('users')
          .update({'notifications': value}).eq('user_id', userId);

      if (Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RadioListTile(
          title: const Text("Toutes les notifications"),
          value: "toute",
          groupValue: _selectedNotification,
          onChanged: _selectedNotification != null
              ? (value) => _updateNotificationSetting(value as String)
              : null,
        ),
        RadioListTile(
          title: const Text("Seulement les messages importants"),
          value: "importante",
          groupValue: _selectedNotification,
          onChanged: _selectedNotification != null
              ? (value) => _updateNotificationSetting(value as String)
              : null,
        ),
        RadioListTile(
          title: const Text("Aucune notification"),
          value: "aucune",
          groupValue: _selectedNotification,
          onChanged: _selectedNotification != null
              ? (value) => _updateNotificationSetting(value as String)
              : null,
        ),
      ],
    );
  }
}
