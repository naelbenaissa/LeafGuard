import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../services/user_service.dart';

/// AppBar personnalisée pour la page détail d'une plante.
///
/// Affiche un bouton "Retour" avec navigation pop, et un avatar utilisateur cliquable
/// menant à la page compte ou authentification selon l'état connecté.
/// Supporte l'affichage conditionnel de l'image de profil récupérée depuis Supabase.
class PlantDetailAppbar extends StatefulWidget implements PreferredSizeWidget {
  const PlantDetailAppbar({super.key});

  // Hauteur fixe de l'AppBar
  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  State<PlantDetailAppbar> createState() => _PlantDetailAppbarState();
}

class _PlantDetailAppbarState extends State<PlantDetailAppbar> {
  String? profileImageUrl; // URL de l'image de profil utilisateur

  @override
  void initState() {
    super.initState();
    // Charge initialement les données de l'utilisateur
    _loadUserProfile();

    // Écoute les changements d'état d'authentification pour recharger le profil
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (mounted) _loadUserProfile();
    });
  }

  /// Récupère les données utilisateur depuis Supabase via le service utilisateur
  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final userData = await UserService().fetchUserData(user.id);
      if (mounted && userData != null && userData['profile_image'] != null) {
        setState(() {
          profileImageUrl = userData['profile_image'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Couleurs adaptées au thème clair/sombre
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final foregroundColor = isDarkMode ? Colors.white : Colors.black;
    final buttonColor = isDarkMode ? Colors.grey[800] : Colors.grey[200]!;
    final shadowColor = isDarkMode ? Colors.black38 : Colors.black12;

    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Padding(
        // Padding en haut pour gérer la barre de statut + espacement horizontal
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          right: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bouton "Retour" avec icône et texte
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: buttonColor,
                    ),
                    child: Icon(Icons.arrow_back, color: foregroundColor, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text("Retour", style: TextStyle(fontSize: 18, color: foregroundColor)),
                ],
              ),
            ),

            // Avatar utilisateur cliquable, navigue vers compte ou page auth
            GestureDetector(
              onTap: () {
                context.pop();
                Future.microtask(() => context.go(user != null ? '/account' : '/auth'));
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: backgroundColor,
                  boxShadow: [
                    BoxShadow(color: shadowColor, blurRadius: 5, spreadRadius: 1),
                  ],
                ),
                child: profileImageUrl != null && profileImageUrl!.isNotEmpty
                    ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: profileImageUrl!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                    const CircularProgressIndicator(strokeWidth: 2),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.red),
                  ),
                )
                    : Icon(Icons.person, color: foregroundColor, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
