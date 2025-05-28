import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Section de l'interface permettant à l'utilisateur de se déconnecter.
class LogoutSection extends StatelessWidget {
  const LogoutSection({super.key});

  /// Effectue la déconnexion de l'utilisateur via Supabase, puis redirige vers la page de connexion.
  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut(); // Déconnexion Supabase
    if (context.mounted) {
      GoRouter.of(context).go('/auth'); // Redirection après déconnexion
    }
  }

  @override
  Widget build(BuildContext context) {
    // Élément d'interface affichant l'action de déconnexion
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text("Se déconnecter"),
      onTap: () => _logout(context),
    );
  }
}
