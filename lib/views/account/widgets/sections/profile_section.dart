import 'package:flutter/material.dart';

/// Section affichant les informations principales du profil utilisateur :
/// - Photo de profil (ou image par défaut)
/// - Nom complet
/// - Adresse email
class ProfileSection extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ProfileSection({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar circulaire affichant l'image de profil ou une image par défaut
        CircleAvatar(
          radius: 50,
          backgroundImage: userData!["profile_image"] != null
              ? NetworkImage(userData!["profile_image"])
              : const AssetImage("assets/img/slogan/pepper_slogan.png")
          as ImageProvider,
        ),
        const SizedBox(height: 20),
        // Affichage du nom complet en texte gras
        Text(
          "${userData!["first_name"]} ${userData!["last_name"]}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // Affichage de l'adresse email de l'utilisateur
        Text(userData!["email"], style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
