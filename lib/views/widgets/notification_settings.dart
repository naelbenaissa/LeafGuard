import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/user_service.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  String? _selectedNotification; // Stocke la valeur sélectionnée actuelle
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _fetchNotificationSetting(); // Récupère la préférence utilisateur au démarrage
  }

  /// Récupérer les préférences de notification via `UserService`
  Future<void> _fetchNotificationSetting() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return; // Pas d'utilisateur connecté

    final userData = await _userService.fetchUserData(userId);
    if (userData != null && userData['notifications'] != null) {
      setState(() {
        _selectedNotification = userData['notifications']; // Met à jour l'état avec la valeur récupérée
      });
    }
  }

  /// Mettre à jour la valeur des notifications via Supabase et fermer la fenêtre
  Future<void> _updateNotificationSetting(String value) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      setState(() {
        _selectedNotification = value; // Mise à jour locale immédiate pour l'affichage
      });

      // Mise à jour côté backend dans la table 'users'
      await Supabase.instance.client
          .from('users')
          .update({'notifications': value})
          .eq('user_id', userId);

      // Ferme la boîte de dialogue si possible
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Ignorer l'erreur silencieusement (ou gérer si besoin)
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Colonne taille minimale verticale
      children: [
        // Option 1 : Toutes les notifications
        RadioListTile(
          title: const Text("Toutes les notifications"),
          value: "toute",
          groupValue: _selectedNotification,
          onChanged: _selectedNotification != null
              ? (value) => _updateNotificationSetting(value as String)
              : null, // Désactivé tant que la valeur n'est pas chargée
        ),
        // Option 2 : Seulement messages importants
        RadioListTile(
          title: const Text("Seulement les messages importants"),
          value: "importante",
          groupValue: _selectedNotification,
          onChanged: _selectedNotification != null
              ? (value) => _updateNotificationSetting(value as String)
              : null,
        ),
        // Option 3 : Aucune notification
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
