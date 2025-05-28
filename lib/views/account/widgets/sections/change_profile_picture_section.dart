import 'package:flutter/material.dart';
import '../../../../services/user_service.dart';

/// Section permettant à l'utilisateur de changer sa photo de profil.
///
/// Affiche une liste d'avatars disponibles. Lorsqu'une image est sélectionnée,
/// elle est mise à jour côté serveur et dans les données locales de l'utilisateur.
class ChangeProfilePictureSection extends StatelessWidget {
  final Map<String, dynamic>? userData; // Données utilisateur actuelles
  final VoidCallback onUpdate; // Callback pour notifier que les données ont été mises à jour
  final bool isExpanded; // Indique si la section est dépliée
  final VoidCallback onTap; // Action à exécuter lors du clic sur la section

  const ChangeProfilePictureSection({
    super.key,
    required this.userData,
    required this.onUpdate,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();

    /// Met à jour l'image de profil de l'utilisateur à partir de l'URL sélectionnée.
    Future<void> updateProfileImage(String newImageUrl) async {
      if (userData == null || userData!["user_id"] == null) return;
      if (newImageUrl.isEmpty) return;

      // Mise à jour de l'image sur le backend
      await userService.updateProfileImage(userData!["user_id"], newImageUrl);

      // Récupération des nouvelles données utilisateur
      final updatedUserData = await userService.fetchUserData(userData!["user_id"]);

      // Mise à jour locale des données utilisateur
      if (updatedUserData != null) {
        userData?.update(
          "profile_image",
              (value) => updatedUserData["profile_image"],
          ifAbsent: () => updatedUserData["profile_image"],
        );
      }

      // Notification de mise à jour
      onUpdate();
    }

    return Column(
      children: [
        // Élément de menu pour changer la photo de profil
        ListTile(
          leading: Icon(
            Icons.person,
            color: isExpanded
                ? Colors.green
                : Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          title: const Text("Changer la photo de profil"),
          onTap: onTap, // Déclenche l'ouverture ou fermeture de la section
        ),

        // Si la section est dépliée, afficher les avatars disponibles
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: userService.getProfileImages().map((imageUrl) {
                bool isSelected = imageUrl == userData?["profile_image"];

                return GestureDetector(
                  onTap: () {
                    if (userData?["user_id"] != null && imageUrl.isNotEmpty) {
                      updateProfileImage(imageUrl);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      // Encadrement vert si l'image est sélectionnée
                      border: isSelected ? Border.all(color: Colors.green, width: 3) : null,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(imageUrl),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
